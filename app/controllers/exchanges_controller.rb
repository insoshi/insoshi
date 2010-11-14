class ExchangesController < ApplicationController
  load_resource :person
  load_and_authorize_resource :exchange, :through => :person
  skip_before_filter :require_activation
  before_filter :login_or_oauth_required
  before_filter :find_worker

  def index
    #@exchanges = @worker.received_exchanges # created_at DESC
    respond_to do |format|
      format.xml { render :xml => @exchanges }
      format.json { render :json => @exchanges.as_json( :include => :req ) }
    end
  end

  def show
    respond_to do |format|
      format.xml { render :xml => @exchange.to_xml( :include => :req ) }
      format.json { render :json => @exchange.as_json( :include => :req ) }
    end
  end

  def new
    if params[:offer]
      @offer = Offer.find(params[:offer])
      if @offer.person != Person.find(params[:person_id])
        flash[:error] = t('error_offer_person_mismatch')
      end
    else
      @req = Req.new
      @req.name = 'Enter description of service here'
    end

    @groups = Person.find(params[:person_id]).groups
    @groups.delete_if {|g| !g.adhoc_currency?}

    respond_to do |format|
      format.html
      format.js
    end
  end

  # this method expects that the form is either referencing an existing offer or accepting a name field for a new req to be created 
  #
  def create
    @exchange = Exchange.new(params[:exchange]) # amount and group_id are the only accessible fields
    @exchange.worker = @person
    @exchange.customer = current_person

    if params[:offer]
      @offer = Offer.find(params[:offer][:id])
      @exchange.amount = @offer.price
      @exchange.metadata = @offer
      @exchange.group = @offer.group
    else
      @req = Req.new(params[:req])

      @req.name = 'Gift transfer' if @req.name.blank? # XML creation might not set this
      @req.group = @exchange.group
      @req.estimated_hours = @exchange.amount
      @req.due_date = Time.now
      @req.person = current_person
      @req.active = false
      @req.save!

      @exchange.metadata = @req
    end


    respond_to do |format|
      if @exchange.save
        flash[:notice] = t('success_credit_transfer_succeeded')
        format.html { redirect_to person_path(@person) and return }
        format.xml { render :xml => @exchange, :status => :created, :location => [@person, @exchange] }
        format.json { render :json => @exchange, :status => :created, :location => [@person, @exchange] }
        format.js
      else
        flash[:error] = t('error_with_credit_transfer')
        @groups = Person.find(params[:person_id]).groups
        format.html { render :action => "new" }
        format.xml { render :xml => @exchange.errors, :status => :unprocessable_entity }
        format.json { render :json => @exchange.errors, :status => :unprocessable_entity }
        format.js { render :nothing => true } # XXX
      end
    end
  end

  def destroy
    @metadata = @exchange.metadata

    begin
      Exchange.transaction do
        @person.account(@exchange.group).withdraw(@exchange.amount)
        current_person.account(@exchange.group).deposit(@exchange.amount)
      end
    rescue
      respond_to do |format|
        flash[:error] = t('error_with_suspension')
        format.html { redirect_to person_path(@person) and return }
      end
    end

    @exchange.destroy
    if @metadata.class == Req
      unless @metadata.active?
        @metadata.destroy
      end
    end
    flash[:success] = t('success_payment_suspended')

    respond_to do |format|
      format.html { redirect_to person_url(current_person) }
    end
  end

end
