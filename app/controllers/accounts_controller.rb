class AccountsController < ApplicationController
  before_filter :find_worker

  def index
    @accounts = @worker.accounts
    # remove accounts associated with deleted groups but do not remove main account
    @accounts.delete_if {|account| account.group.nil? and !account.group_id.nil? }

    # create a pseudogroup for the main account. this will make processing easier on the client
    @accounts.each do |account|
      if account.group.nil?
        account.group = Group.new({:name => "main", :description => "", :unit => "hours"})
      end
    end

    respond_to do |format|
      format.xml { render :xml => @accounts.to_xml(:include => {:group => {:methods => [:thumbnail, :icon], :only => [:id,:name,:description,:unit,:thumbnail,:icon]} }) }
      format.json { render :json => @accounts.as_json(:include => {:group => {:methods => [:thumbnail, :icon], :only => [:id,:name,:description,:unit,:thumbnail,:icon]} }) }
    end
  end

  def show
    @account = Account.find(params[:id])
    if @account.group.nil?
      @exchanges = @worker.received_exchanges(@account.group_id)
      @units = "hours"
    else
      @exchanges = @worker.received_group_exchanges(@account.group_id)
      @units = @account.group.unit
    end
  end

private

  def find_worker
    @worker_id = params[:person_id]
    redirect_to home_url and return unless @worker_id
    @worker = Person.find(@worker_id)
  end
end
