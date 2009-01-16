class ExchangesController < ApplicationController
  skip_before_filter :require_activation
  before_filter :login_or_oauth_required
  before_filter :find_worker

  def index
    @exchanges = @worker.exchanges.find(:all, :order => 'created_at DESC')
    respond_to do |format|
      format.xml { render :xml => @exchanges }
      format.json { render :json => @exchanges.to_json( :include => :req ) }
    end
  end

  def show
    @exchange = Exchange.find(params[:id])
    respond_to do |format|
      format.xml { render :xml => @exchange }
      format.json { render :json => @exchange.to_json( :include => :req ) }
    end
  end

  def new
    @req = Req.new
    @req.name = 'Gift transfer'
    @exchange = Exchange.new
  end

  def create
    @exchange = Exchange.new(params[:exchange]) # amount is the only accessible field
    @req = Req.new(params[:req])

    begin
      Exchange.transaction do
        @exchange.worker = @worker
        @exchange.customer = current_person

        if @req.name.blank?
          @req.name = 'Gift transfer' # XML creation might not set this
        end
        @req.estimated_hours = @exchange.amount
        @req.due_date = Time.now
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
        format.json { render :json => @exchange.errors, :status => :unprocessable_entity }
        return
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
      format.json { render :json => @exchange, :status => :created, :location => [@worker, @exchange] }
    end
  end

private
  def find_worker
    @worker_id = params[:person_id]
    redirect_to home_url and return unless @worker_id
    @worker = Person.find(@worker_id)
  end
end
