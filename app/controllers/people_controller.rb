class PeopleController < ApplicationController
  
  skip_before_filter :require_activation, :only => :verify_email
  skip_before_filter :admin_warning, :only => [ :show, :update ]
  before_filter :login_or_oauth_required, :only => [ :index, :show, :edit, :update ]
  before_filter :correct_person_required, :only => [ :edit, :update ]
  before_filter :setup
  before_filter :setup_zips, :only => [:index, :show]
  
  def index
    @zipcode = ""
    if global_prefs.zipcode_browsing? && params[:zipcode]
      @people = Person.mostly_active_with_zipcode(params[:zipcode],params[:page])
      @zipcode = "(#{params[:zipcode]})"
    else
      if params[:sort]
        if "newest" == params[:sort]
          @people = Person.mostly_active_newest(params[:page])
        end
      else
        # XXX temp hack for postgresql
          @people = Person.mostly_active_newest(params[:page])
        #@people = Person.mostly_active_alpha(params[:page])
        #@people.add_missing_links(('A'..'Z').to_a)
      end
    end

    respond_to do |format|
      format.html
    end
  end
  
  def show
    person_id = ( 0 == params[:id].to_i ) ? current_person.id : params[:id]
    @person = Person.find(person_id)
    unless @person.active? or current_person.admin?
      flash[:error] = "That person is not active"
      redirect_to home_url and return
    end
    if logged_in?
      @some_contacts = @person.some_contacts
      @common_contacts = current_person.common_contacts_with(@person)
      @groups = current_person == @person ? @person.groups : @person.groups_not_hidden
      @own_groups = current_person == @person ? @person.own_groups : @person.own_not_hidden_groups
    end
    respond_to do |format|
      format.html
      if current_person == @person
        format.json { render :json => @person.to_json( :methods => :icon, :only => [:id, :name, :description, :created_at, :identity_url,:icon], :include => {:accounts => {:only => [:balance,:group_id]}, :groups => {:only => [:id,:name]}, :own_groups => { :methods => [:icon,:thumbnail], :only => [:id,:name,:mode,:icon,:thumbnail] } }) }
        format.xml { render :xml => @person.to_xml( :methods => :icon, :only => [:id, :name, :description, :created_at, :identity_url,:icon], :include => {:accounts => {:only => [:balance,:group_id]}, :groups => {:only => [:id,:name]}, :own_groups => { :methods => [:icon,:thumbnail], :only => [:id,:name,:mode,:icon,:thumbnail] }}) }
      else
        format.json { render :json => @person.to_json( :methods => :icon, :only => [:id, :name, :description, :created_at, :identity_url,:icon], :include => {:accounts => {:only => [:balance,:group_id]}, :groups_not_hidden => {:only => [:id,:name]}, :own_not_hidden_groups => {:only => [:id,:name] }}) }
        format.xml { render :xml => @person.to_xml( :methods => :icon, :only => [:id, :name, :description, :created_at, :identity_url,:icon], :include => {:accounts => {:only => [:balance,:group_id]}, :groups_not_hidden => {:only => [:id,:name]}, :own_not_hidden_groups => {:only => [:id,:name] }}) }
      end
    end
  end
  
  def new
    @body = "register single-col"
    @body = @body + " yui-skin-sam"
    @person = Person.new
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
    @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
    respond_to do |format|
      format.html
    end
  end

  def create
    cookies.delete :auth_token
    @person = Person.new(params[:person])
    respond_to do |format|
      @person.email_verified = false if global_prefs.email_verifications?
      @person.identity_url = session[:verified_identity_url]
      @person.save
      if @person.errors.empty?
        session[:verified_identity_url] = nil
        if global_prefs.can_send_email? && !global_prefs.new_member_notification.nil?
          PersonMailer.deliver_registration_notification(@person)
        end
        if global_prefs.email_verifications?
          @person.email_verifications.create
          flash[:notice] = %(Thanks for signing up! Check your email
                             to activate your account.)
          format.html { redirect_to(home_url) }
        else
          self.current_person = @person
          flash[:notice] = "Thanks for signing up!"
          format.html { redirect_back_or_default(home_url) }
        end
      else
        @body = "register single-col"
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        format.html { if @person.identity_url.blank? 
                        render :action => 'new'
                      else
                        render :partial => "shared/personal_details.html.erb", :object => @person, :layout => 'application'
                      end
                    }
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
    verification = EmailVerification.find_by_code(params[:id])
    if verification.nil?
      flash[:error] = "Invalid email verification code"
      redirect_to home_url
    else
      cookies.delete :auth_token
      person = verification.person
      person.email_verified = true; person.save!
      self.current_person = person
      flash[:success] = "Email verified. Your profile is active!"
      redirect_to person
    end
  end

  def edit
    @body = @body + " yui-skin-sam"
    @person = Person.find(params[:id])
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
    @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
    respond_to do |format|
      format.html
    end
  end

  def update
    @person = Person.find(params[:id])

    unless(params[:task].blank?)
      if current_person.admin?
        @person.toggle!(params[:task])
        respond_to do |format|
          flash[:success] = "#{CGI.escapeHTML @person.name} updated."
          format.html { redirect_to :back }
        end
        return
      end
    end

    respond_to do |format|
      case params[:type]
      when 'info_edit'
        if !preview? and @person.update_attributes(params[:person])
          flash[:success] = 'Profile updated!'
          format.html { redirect_to(@person) }
        else
          @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
          @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
          if preview?
            @preview = @person.description = params[:person][:description]
          end
          format.html { render :action => "edit" }
        end
      when 'password_edit'
        if global_prefs.demo?
          flash[:error] = "Passwords can't be changed in demo mode."
          redirect_to @person and return
        end
        if @person.change_password?(params[:person])
          flash[:success] = 'Password changed.'
          format.html { redirect_to(@person) }
        else
          @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
          @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
          format.html { render :action => "edit" }
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
  
  def request_memberships
    @person = Person.find(params[:id])
    @requested_memberships = @person.requested_memberships
  end
  
  def invitations
    @person = Person.find(params[:id])
    @invitations = @person.invitations
  end
  
  private

    def setup
      @body = "person"
    end

    def setup_zips
      @zips = []
      @zips = Address.find(:all).map {|a| a.zipcode_plus_4}
      @zips.uniq!
      @zips.delete_if {|z| z.blank?}
      @zips.sort!
    end

    def correct_person_required
      redirect_to home_url unless ( current_person.admin? or Person.find(params[:id]) == current_person )
    end
    
    def preview?
      params["commit"] == "Preview"
    end
end
