class InvitationsController < ApplicationController
  before_filter :login_required, :credit_card_required

  def edit
    @invitation = current_person.invitations.find(params[:id])
  end

  def update
    @invitation = current_person.invitations.find(params[:id])
    name = @invitation.group.name

    case params[:commit]
    when "Accept"
      @invitation.accept
      flash[:notice] = t('notice_accepted_membership_with') + " #{name}"
      redirect_to group_path(@invitation.group)
    when "Decline"
      @invitation.destroy
      flash[:notice] = t('notice_declined_membership_for') + " #{name}"
      redirect_to group_path(current_person.default_group)
    end
  end
end
