class ExchangesController < ApplicationController
  before_filter :login_required
  before_filter :find_worker

  def index
    @exchanges = @worker.exchanges.find(:all, :order => 'created_at DESC')
    respond_to do |format|
      format.xml { render :xml => @exchanges }
    end
  end

  def show
    @exchange = Exchange.find(params[:id])
    respond_to do |format|
      format.xml { render :xml => @exchange }
    end
  end

  def new
    @exchange = Exchange.new
  end

  def create
    @exchange = Exchange.new(params[:exchange]) # amount is the only accessible field
    begin
      Exchange.transaction do
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
      respond_to do |format|
        flash[:error] = "Error with transfer."
        format.html { render :action => "new" and return }
        format.xml { render :xml => @exchange.errors, :status => :unprocessable_entity }
      end
    end

    exchange_note = Message.new()
    exchange_note.subject = "TRANSFER: " + @exchange.amount.to_s + " hours - " + @req.name 
    exchange_note.content = "This is an automatically generated system notice. " + current_person.name + " has gifted you " + @exchange.amount.to_s + " hours."
    exchange_note.sender = current_person
    exchange_note.recipient = @worker
    exchange_note.save!

    respond_to do |format|
      flash[:notice] = "Transfer succeeded."
      format.html { redirect_to person_path(@worker) and return }
      format.xml { render :xml => @exchange, :status => :created, :location => [@worker, @exchange] }
    end
  end

private
  def find_worker
    @worker_id = params[:person_id]
    redirect_to home_url and return unless @worker_id
    @worker = Person.find(@worker_id)
  end
end
