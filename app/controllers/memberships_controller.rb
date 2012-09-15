class MembershipsController < ApplicationController
  before_filter :login_required
  load_resource :group
  load_and_authorize_resource :membership, :through => :group, :shallow => true

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    respond_to do |format|
      format.html {redirect_to @membership.group}
    end
  end

  def index
    @selected_category = params[:category_id].nil? ? nil : Category.find(params[:category_id])
    @selected_neighborhood = params[:neighborhood_id].nil? ? nil : Neighborhood.find(params[:neighborhood_id])

    @memberships = Membership.custom_search(@selected_neighborhood || @selected_category, 
                                            @group, 
                                            params[:page], 
                                            AJAX_POSTS_PER_PAGE, 
                                            params[:search]
                                            )

    respond_to do |format|
      format.js
    end
  end

  def show
    @person = @membership.person
    @account = @person.account(@membership.group)
    respond_to do |format|
      format.js
      format.html { redirect_to('/groups/' + @membership.group.id.to_s + '#memberships/' + @membership.id.to_s)}
    end
  end

  def edit
    @account = @membership.account
  end
  
  def create

    respond_to do |format|
      @hr = Membership.request(current_person, @group)
      if @hr
        if @group.public?
          flash[:notice] = t('notice_you_have_joined') + " '#{@group.name}'"
        else
          flash[:notice] = t('notice_membership_request_sent')
        end
        format.html { redirect_to(home_url) }
        format.js
      else
        # This should only happen when people do something funky
        # like trying to join a group that has a request pending
        flash[:notice] = t('notice_membership_invalid')
        format.html { redirect_to(home_url) }
        format.js
      end
    end
  end
  
  def update
    respond_to do |format|
      if @membership.update_attributes(params[:membership])
        flash[:notice] = 'Membership was successfully updated.'
        format.html { redirect_to(members_group_path(@membership.group)) }
      else
        format.html { render :action => "edit" }
      end
    end  
  end
  
  def destroy
    @membership.breakup
    
    respond_to do |format|
      flash[:notice] = t('success_you_have_left_the_group') + " #{@membership.group.name}"
      format.html { redirect_to( person_url(current_person)) }
      format.js
    end
  end
  
  def unsuscribe
    @membership.breakup
    
    respond_to do |format|
      flash[:success] = t('success_you_have_unsubscribed') + " '#{@membership.person.display_name}' #{t('success_from_group')} '#{@membership.group.name}'"
      format.html { redirect_to(members_group_path(@membership.group)) }
    end
  end
  
  def suscribe
    @membership.accept
    after_transaction { PersonMailerQueue.membership_accepted(@membership) }

    respond_to do |format|
      flash[:success] = t('success_you_have_accepted') + " '#{@membership.person.display_name}' #{t('success_for_group')} '#{@membership.group.name}'"
      format.html { redirect_to(members_group_path(@membership.group)) }
    end
  end
  
end
