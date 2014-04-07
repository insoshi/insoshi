class AccountsController < ApplicationController
  before_filter :login_or_oauth_required, :credit_card_required
  load_resource :person
  load_and_authorize_resource :account, :through => :person

  def index
  end

  def update
    if @account.update_attributes(params[:account])
      flash[:success] = t('success_account_updated')
      redirect_to(edit_membership_path(@account.membership))
    else
      flash[:error] = t('error_account_update_failed')
      redirect_to(edit_membership_path(@account.membership))
    end
  end

  def show
    @account = Account.find(params[:id])
    unless (@account.group.private_txns? and not current_person?(@person))
      @exchanges = @person.received_group_exchanges(@account.group_id)
    end
    respond_to do |format|
      format.html
      format.js {render :action => 'reject' if not request.xhr?}
    end
  end

end
