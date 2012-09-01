class AccountsController < ApplicationController
  before_filter :login_or_oauth_required
  load_resource :person
  load_and_authorize_resource :account, :through => :person

  def index
#    @accounts = @person.accounts
    # remove accounts associated with deleted groups
    @accounts.delete_if {|account| account.group.nil? }

    respond_to do |format|
      format.xml { render :xml => @accounts.to_xml(:include => {:group => {:methods => [:thumbnail, :icon], :only => [:id,:name,:description,:unit,:thumbnail,:icon]} }) }
      format.json { render :json => @accounts.as_json(:include => {:group => {:methods => [:thumbnail, :icon], :only => [:id,:name,:description,:unit,:thumbnail,:icon]} }) }
    end
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
    @exchanges = @person.received_group_exchanges(@account.group_id)
    respond_to do |format|
      format.html
      format.js
    end
  end

end
