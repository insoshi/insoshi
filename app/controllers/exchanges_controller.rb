class ExchangesController < ApplicationController
  before_filter :login_required
  before_filter :find_worker

  def new
    @exchange = Exchange.new
  end

  def create
    begin
      Exchange.transaction do
        @exchange = Exchange.new(params[:exchange]) # amount is the only accessible field
        @exchange.worker = @worker
        @exchange.customer = current_person

        @req = Req.new( {:name => "Gift transfer", :estimated_hours => @exchange.amount, :due_date => Time.now } )
        @req.person = current_person
        @req.active = false
        @req.save!

        @exchange.req = @req
        @exchange.save!

        @worker.account.deposit(@exchange.amount)
        current_person.account.withdraw(@exchange.amount)
      end
    rescue
      flash[:error] = "Error with transfer."
      render :action => "new" and return
    end

    exchange_note = Message.new()
    exchange_note.subject = "TRANSFER: " + @exchange.amount.to_s + " hours - " + @req.name 
    exchange_note.content = "This is an automatically generated system notice. " + current_person.name + " has gifted you " + @exchange.amount.to_s + " hours."
    exchange_note.sender = current_person
    exchange_note.recipient = @worker
    exchange_note.save!

    flash[:notice] = "Transfer succeeded."
    redirect_to person_path(@worker) and return
  end

private
  def find_worker
    @worker_id = params[:person_id]
    redirect_to home_url and return unless @worker_id
    @worker = Person.find(@worker_id)
  end
end
