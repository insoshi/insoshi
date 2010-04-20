class MembershipsController < ApplicationController
  before_filter :login_required
  before_filter :authorize_person, :only => [:edit, :update, :destroy, :suscribe, :unsuscribe]
  
  
  def edit
    @membership = Membership.find(params[:id])
  end
  
  def create
    @group = Group.find(params[:group_id])

    respond_to do |format|
      if Membership.request(current_person, @group)
        if @group.public?
          flash[:notice] = t('notice_you_have_joined') + " '#{@group.name}'"
        else
          flash[:notice] = t('notice_membership_request_sent')
        end
        format.html { redirect_to(home_url) }
      else
        # This should only happen when people do something funky
        # like trying to join a group that has a request pending
        flash[:notice] = t('notice_membership_invalid')
        format.html { redirect_to(home_url) }
      end
    end
  end
  
  def update
    
    respond_to do |format|
      membership = @membership
      name = membership.group.name
      case params[:commit]
      when "Accept"
        @membership.accept
        PersonMailer.deliver_invitation_accepted(@membership)
        flash[:notice] = %(#{t('notice_accepted_membership_with')}
                           <a href="#{group_path(@membership.group)}">#{name}</a>)
      when "Decline"
        @membership.breakup
        flash[:notice] = t('notice_declined_membership_for') + " #{name}"
      end
      format.html { redirect_to(home_url) }
    end
  end
  
  def destroy
    @membership = Membership.find(params[:id])
    @membership.breakup
    
    respond_to do |format|
      flash[:success] = t('success_you_have_left_the_group') + " #{@membership.group.name}"
      format.html { redirect_to( person_url(current_person)) }
    end
  end
  
  def unsuscribe
    @membership = Membership.find(params[:id])
    @membership.breakup
    
    respond_to do |format|
      flash[:success] = t('success_you_have_unsubscribed') + " '#{@membership.person.name}' #{t('success_from_group')} '#{@membership.group.name}'"
      format.html { redirect_to(members_group_path(@membership.group)) }
    end
  end
  
  def suscribe
    @membership = Membership.find(params[:id])
    @membership.accept
    PersonMailer.deliver_membership_accepted(@membership)

    respond_to do |format|
      flash[:success] = t('success_you_have_accepted') + " '#{@membership.person.name}' #{t('success_for_group')} '#{@membership.group.name}'"
      format.html { redirect_to(members_group_path(@membership.group)) }
    end
  end
  
  private 
  
  # Make sure the current person is correct for this connection.
    def authorize_person
      @membership = Membership.find(params[:id],
                                    :include => [:person, :group])
      if  !params[:invitation].blank? or params[:action] == 'suscribe' or params[:action] == 'unsuscribe'
        unless current_person?(@membership.group.owner)
          flash[:error] = t('error_invalid_connection')
          redirect_to home_url
        end
      else
        unless current_person?(@membership.person)
          flash[:error] = t('error_invalid_connection')
          redirect_to home_url
        end
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = t('error_invalid_or_expired_membership')
      redirect_to home_url
    end

end
