class AccountsController < ApplicationController
  before_filter :find_worker

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
