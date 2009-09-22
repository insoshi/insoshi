class ExchangesController < ApplicationController
  skip_before_filter :require_activation
  before_filter :login_or_oauth_required
  before_filter :find_worker

  def index
    @exchanges = @worker.received_exchanges # created_at DESC
    respond_to do |format|
      format.xml { render :xml => @exchanges }
      format.json { render :json => @exchanges.to_json( :include => :req ) }
    end
  end

  def show
    @exchange = Exchange.find(params[:id])
    respond_to do |format|
      format.xml { render :xml => @exchange.to_xml( :include => :req ) }
      format.json { render :json => @exchange.to_json( :include => :req ) }
    end
  end

  # this form is for a direct payment to a member without an existing req or offer
  # XXX although, we may like to allow customer to choose from her existing reqs in this form
  # -a payment associated with a req is initiated through bids/bid partial and made through Bid#update
  # -a payment associated with an offer is initiated through Offer#show and made through Exchange#create
  def new
    @req = Req.new
    @req.name = 'Enter description of service here'
    @groups = Person.find(params[:person_id]).groups
    @groups.delete_if {|g| !g.adhoc_currency?}
    @exchange = Exchange.new
  end

  # this method expects that the form is either referencing an existing offer or accepting a name field for a new req to be created 
  #
  def create
    @exchange = Exchange.new(params[:exchange]) # amount and group_id are the only accessible fields
    @req = Req.new(params[:req])

    @req.name = 'Gift transfer' if @req.name.blank? # XML creation might not set this
    @req.estimated_hours = @exchange.amount
    @req.due_date = Time.now
    @req.person = current_person
    @req.active = false
    @req.save!

    @exchange.worker = @worker
    @exchange.customer = current_person
    @exchange.metadata = @req


    respond_to do |format|
      if @exchange.save
        flash[:notice] = "Transfer succeeded."
        format.html { redirect_to person_path(@worker) and return }
        format.xml { render :xml => @exchange, :status => :created, :location => [@worker, @exchange] }
        format.json { render :json => @exchange, :status => :created, :location => [@worker, @exchange] }
      else
        flash[:error] = "Error with transfer."
        @groups = Person.find(params[:person_id]).groups
        req_name = @req.name
        @req.destroy
        @req = Req.new
        @req.name = req_name
        format.html { render :action => "new" }
        format.xml { render :xml => @exchange.errors, :status => :unprocessable_entity }
        format.json { render :json => @exchange.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @exchange = Exchange.find(params[:id])
    @metadata = @exchange.metadata

    begin
      Exchange.transaction do
        @worker.account.withdraw(@exchange.amount)
        current_person.account.deposit(@exchange.amount)
      end
    rescue
      respond_to do |format|
        flash[:error] = "Error with suspension of payment."
        format.html { redirect_to person_path(@worker) and return }
      end
    end

    @exchange.destroy
    if @metadata.class == Req
      unless @metadata.active?
        @metadata.destroy
      end
    end
    flash[:success] = "Payment suspended."

    respond_to do |format|
      format.html { redirect_to person_url(current_person) }
    end
  end

private
  def find_worker
    @worker_id = params[:person_id]
    redirect_to home_url and return unless @worker_id
    @worker = Person.find(@worker_id)
  end
end
