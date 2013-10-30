class ExchangesController < ApplicationController
  load_resource :person
  load_and_authorize_resource :exchange, :through => :person
  skip_before_filter :require_activation
  before_filter :login_or_oauth_required

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    respond_to do |format|
      format.html {redirect_to @person}
    end
  end

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
      if @offer.person != @person
        flash[:error] = t('error_offer_person_mismatch')
      end
    else
      if params[:group]
        @group = Group.find(params[:group])
      else
        @group = current_person.default_group
      end
      if params[:customer]
        @customer_id = params[:customer]
      end
      @req = Req.new
    end

    # XXX @groups not used in new ajax ui
    @groups = @person.groups
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
    unless @exchange.customer.present?
      @exchange.customer = current_person
    end

    if params[:offer]
      @offer = Offer.find(params[:offer][:id])
      @exchange.amount = calculate_offer_amount
      @exchange.offer_count = get_offer_count
      @exchange.metadata = @offer
      # XXX maybe cleaner to let the exchange object assign group_id itself?
      @exchange.group_id = @offer.group.adhoc_currency? ? @offer.group_id : global_prefs.default_group_id
    else
      @req = Req.new(params[:req])

      @req.name = 'Gift transfer' if @req.name.blank? # XML creation might not set this
      @req.group = @exchange.group
      @req.estimated_hours = @exchange.amount
      @req.due_date = Time.now
      @req.person = @exchange.customer
      @req.biddable = false
      @req.save!

      @exchange.metadata = @req
    end


    respond_to do |format|
      if @exchange.save
        if !current_token.nil? && current_token.action_id == 'single_payment'
          current_token.invalidate!
        end
        flash[:notice] = t('success_credit_transfer_succeeded')
        format.html { redirect_to person_path(@person) and return }
        format.xml { render :xml => @exchange, :status => :created, :location => [@person, @exchange] }
        format.json { render :json => @exchange, :status => :created, :location => [@person, @exchange] }
        format.js
      else
        flash[:error] = t('error_with_credit_transfer')
        @groups = Person.find(params[:person_id]).groups
        @group = params[:group].nil? ? current_person.default_group : Group.find(params[:group])
        format.html { render :action => "new" }
        format.xml { render :xml => @exchange.errors, :status => :unprocessable_entity }
        format.json { render :json => @exchange.errors, :status => :unprocessable_entity }
        format.js { render :action => "new" }
      end
    end
  end

  def destroy
    @exchange.destroy
    flash[:success] = t('success_payment_suspended')

    respond_to do |format|
      format.html { redirect_to person_url(current_person) }
    end
  end

  private
  
  def get_offer_count
    if params[:offer][:count].blank?
      1
    else
      params[:offer][:count].to_i if (params[:offer][:count].to_i > 0 && params[:offer][:count].to_i <= @offer.available_count)
    end
  end
  
  def calculate_offer_amount
    if params[:offer][:count].blank? 
      @offer.price
    else
      @offer.price * params[:offer][:count].to_i if (params[:offer][:count].to_i > 0 && params[:offer][:count].to_i <= @offer.available_count)
    end
  end
end
