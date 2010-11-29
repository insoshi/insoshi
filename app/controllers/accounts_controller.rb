class AccountsController < ApplicationController
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
      flash[:notice] = 'credit limit updated'
      redirect_to(edit_membership_path(@account.membership))
    else
      flash[:error] = 'credit limit update failed'
      redirect_to(edit_membership_path(@account.membership))
    end
  end

  def show
    @account = Account.find(params[:id])
    @exchanges = @person.received_group_exchanges(@account.group_id)
    @units = @account.group.unit
  end

end
