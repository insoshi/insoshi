class PeopleController < ApplicationController

  skip_before_filter :require_activation, :only => :verify_email
  skip_before_filter :admin_warning, :only => [ :show, :update ]
  #before_filter :login_or_oauth_required, :only => [ :index, :show, :edit, :update ]
  before_filter :login_required, :only => [ :index, :show, :edit, :update ]
  before_filter :correct_person_required, :only => [ :edit, :update ]
  before_filter :setup_zips, :only => [:index, :show]

  def index
    @zipcode = ""
    if global_prefs.zipcode_browsing? && params[:zipcode]
      @people = Person.
        with_zipcode(params[:zipcode]).
        mostly_active.
        by_name.
        paginate(:page => params[:page], :per_page => RASTER_PER_PAGE)
      @zipcode = "(#{params[:zipcode]})"
    else
      if params[:sort]
        if "alpha" == params[:sort]
          @people = Person.
            by_first_letter.
            mostly_active.
            paginate(:page => params[:page], :per_page => RASTER_PER_PAGE, :group_by => "first_letter")
          @people.add_missing_links(('A'..'Z').to_a)
        end
      else
        @people = Person.
          by_newest.
          mostly_active.
          paginate(:page => params[:page], :per_page => RASTER_PER_PAGE)
      end
    end

    respond_to do |format|
      format.html
    end
  end

  def show
    person_id = ( 0 == params[:id].to_i ) ? current_person.id : params[:id]
    @person = Person.find(person_id)
    unless @person.active? || current_person.admin? || (global_prefs.whitelist? && current_person.activator?)
      flash[:error] = t('error_person_inactive')
      redirect_to home_url and return
    end
    if logged_in?
      @groups = current_person == @person ? @person.groups : @person.groups_not_hidden
    end
    respond_to do |format|
      format.html
      if current_person == @person
        format.json { render :json => @person.as_json( :methods => :icon, :only => [:id, :name, :description, :created_at, :identity_url,:icon], :include => {:accounts => {:only => [:balance_with_initial_offset,:group_id]}, :groups => {:only => [:id,:name]}, :own_groups => { :methods => [:icon,:thumbnail], :only => [:id,:name,:mode,:icon,:thumbnail] } }) }
        format.xml { render :xml => @person.to_xml( :methods => :icon, :only => [:id, :name, :description, :created_at, :identity_url,:icon], :include => {:accounts => {:only => [:balance_with_initial_offset,:group_id]}, :groups => {:only => [:id,:name]}, :own_groups => { :methods => [:icon,:thumbnail], :only => [:id,:name,:mode,:icon,:thumbnail] }}) }
      else
        format.json { render :json => @person.as_json( :methods => :icon, :only => [:id, :name, :description, :created_at, :identity_url,:icon], :include => {:accounts => {:only => [:balance_with_initial_offset,:group_id]}, :groups_not_hidden => {:only => [:id,:name]}}) }
        format.xml { render :xml => @person.to_xml( :methods => :icon, :only => [:id, :name, :description, :created_at, :identity_url,:icon], :include => {:accounts => {:only => [:balance_with_initial_offset,:group_id]}, :groups_not_hidden => {:only => [:id,:name]}}) }
      end
    end
  end

  def new
    @body = "register single-col"
    @person = Person.new
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
    @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
    respond_to do |format|
      format.html
    end
  end

  def create
    @person = Person.new(params[:person])
    @person.email_verified = false if global_prefs.email_verifications?
    @person.save do |result|
      respond_to do |format|
        if result
          if global_prefs.can_send_email? && !global_prefs.new_member_notification.blank?
            after_transaction { PersonMailerQueue.registration_notification(@person) }
          end
          if global_prefs.email_verifications?
            @person.deliver_email_verification!
            flash[:notice] = t('notice_thanks_for_signing_up_check_email')
            format.html { redirect_to(home_url) }
          else
            # XXX self.current_person = @person
            flash[:notice] = t('notice_thanks_for_signing_up')
            format.html { redirect_to(home_url) }
          end
        else
          @body = "register single-col"
          @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
          @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
          format.html { render :action => 'new' }
        end
      end
    end
  rescue ActiveRecord::StatementInvalid
    # Handle duplicate email addresses gracefully by redirecting.
    redirect_to home_url
  rescue ActionController::InvalidAuthenticityToken
    # Experience has shown that the vast majority of these are bots
    # trying to spam the system, so catch & log the exception.
    warning = "ActionController::InvalidAuthenticityToken: #{params.inspect}"
    logger.warn warning
    redirect_to home_url
  end

  def verify_email
    person = Person.find_using_perishable_token(params[:id])
    unless person
      flash[:error] = t('error_invalid_email_verification_code')
      redirect_to home_url
    else
      person.email_verified = true
      person.save!
      if Person.global_prefs.whitelist?
        flash[:success] = t('success_email_verified_whitelist')
      else
        flash[:success] = t('success_email_verified')
      end
      redirect_to login_url
    end
  end

  def edit
    logger.info "XXX id: #{params[:id]}"
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
    @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
    respond_to do |format|
      format.html
    end
  end

  def update
    if cancel?
      flash[:notice] = "#{CGI.escapeHTML @person.display_name} " + t('cancelled')
      redirect_to person_path(@person)
      return
    end

    unless(params[:task].blank?)
      @person.toggle!(params[:task])
      if 'deactivated' == params[:task]
        @person.update_attributes!(:sponsor => current_person)
      end
      flash[:success] = "#{CGI.escapeHTML @person.display_name} " + t('success_updated')
      redirect_to person_path(@person)
      return
    end

    case params[:type]
    when 'info_edit'
      respond_to do |format|
        if @person.update_attributes(params[:person])
          flash[:success] = t('success_profile_updated')
          format.html { redirect_to(@person) }
        else
          @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
          @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
          format.html { render :action => "edit" }
        end
      end
    when 'password_edit'
      if global_prefs.demo?
        flash[:error] = t('error_password_cant_be_changed')
        redirect_to @person and return
      end
      respond_to do |format|
        if @person.change_password?(params[:person])
          flash[:success] = t('success_password_changed')
          format.html { redirect_to(@person) }
        else
          @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
          @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
          format.html { render :action => "edit" }
        end
      end
      #when 'openid_edit'
    else
      @person.attributes = params[:person]
      @person.save do |result|
        respond_to do |format|
          if result
            flash[:success] = t('success_profile_updated')
            format.html { redirect_to(@person) }
          else
            @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
            @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
            format.html { render :action => "edit" }
          end
        end
      end
    end
  end

  def common_contacts
    @person = Person.find(params[:id])
    @common_contacts = @person.common_contacts_with(current_person,
                                                    params[:page])
    respond_to do |format|
      format.html
    end
  end

  def groups
    @person = Person.find(params[:id])
    @groups = current_person == @person ? @person.groups : @person.groups_not_hidden

    respond_to do |format|
      format.html
    end
  end

  def admin_groups
    @person = Person.find(params[:id])
    @groups = @person.own_groups
    render :action => :groups
  end

  def su
    @person = Person.find(params[:id])
    if can?(:su, @person)
      @person_session = PersonSession.create(@person)
    else
      flash[:error] = t('error_admin_access_required')
    end

    respond_to do |format|
      format.html { redirect_to(@person) }
    end
  end

  private

    def setup_zips
      @zips = []
      @zips = Address.find(:all).map {|a| a.zipcode_plus_4}
      @zips.uniq!
      @zips.delete_if {|z| z.blank?}
      @zips.sort!
    end

    def correct_person_required
      @person = Person.find(params[:id])
      unless(params[:task].blank?)
        can_change_status = case params[:task]
        when 'deactivated'
          current_person.admin? || (global_prefs.whitelist? && current_person.activator?)
        when 'activator'
          current_person.admin?
        end
        flash[:error] = t('error_admin_access_required') unless can_change_status
        redirect_to person_path(@person) unless can_change_status
      else
        redirect_to home_url unless ( current_person.admin? or Person.find(params[:id]) == current_person )
      end
    end

    def cancel?
      params["commit"] == t('button_cancel');
    end
end
