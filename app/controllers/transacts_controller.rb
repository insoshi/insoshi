class TransactsController < ApplicationController
  skip_before_filter :require_activation
  prepend_before_filter :login_or_oauth_required
  before_filter :find_group_by_asset
  skip_before_filter :verify_authenticity_token, :set_person_locale, :if => :oauth?

  def index
    @transactions = current_person.transactions.select {|transact| transact.group == @group}
    respond_to do |format|
      format.html
      format.xml { render :xml => @transactions.to_xml(:root => "txns") }
      format.json { render :json => @transactions.as_json }
    end
  end

  def show
    @transact = current_person.transactions.find(params[:id])
    if nil == @transact
        flash[:error] = t('error_could_not_find_transaction')
        redirect_to home_url
        return
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => @transact.to_xml }
      format.json { render :json => @transact.as_json }
    end
  end

  def new
    @amount = params[:amount] || ""
    if params[:to]
      @worker = opentransact_find_worker(params[:to])
      if nil == @worker
        flash[:error] = t('error_could_not_find_payee')
        render :action => "new"
        return
      end
    end
  end

  def create
    # Transact.to and Transact.memo - makes @transact look opentransacty
    #
    @transact = Transact.new(:to => params[:to], :memo => params[:memo], :amount => params[:amount], :callback_url => params[:callback_url], :redirect_url => params[:redirect_url])

    @worker = opentransact_find_worker(params[:to])
    if nil == @worker
      respond_to do |format|
        format.html do
          flash[:error] = t('error_could_not_find_payee')
          render :action => "new"
        end
        format.json do
          @transact.errors.add_to_base(t('error_could_not_find_payee'))
          render :json => @transact.as_json, :status => :unprocessable_entity
        end
      end
      return
    end

    @transact.customer = current_person
    @transact.worker = @worker
    @transact.group = @group

    @transact.metadata = @transact.create_req(params[:memo])

    if can?(:create, @transact) && @transact.save
      if !current_token.nil? && current_token.action_id == 'single_payment'
        current_token.invalidate!
      end
      if @transact.redirect_url.blank?
        flash[:notice] = t('notice_transfer_succeeded')
        respond_to do |format|
          format.html { redirect_to person_path(@worker) }
          format.json { render :json => @transact.as_json }
          format.xml { render :xml => @transact.to_xml }
        end
      else
        @transact.redirect_url << "?status=ok"
        redirect_to @transact.redirect_url
      end
    else
      respond_to do |format|
        format.html do
          flash[:error] = t('error_with_transfer')
          @transact.metadata.destroy
          render :action => "new"
        end
        format.json do
          @transact.errors.add(:base, t('error_with_credit_transfer'))
          render :json => @transact.as_json, :status => :unprocessable_entity
        end
      end
    end

  end

  def opentransact_find_worker(payee)
    # assume identifier is either an email address or a url
    if payee.split('@').size == 2
      @worker = Person.find_by_email(payee)
    else
      @worker = Person.find_by_openid_identifier(OpenIdAuthentication.normalize_identifier(CGI.unescape(payee)))
    end
  end

  private

  def find_group_by_asset
    @group = Group.by_opentransact(params[:asset])
    if oauth?
      unless params[:asset]
        invalid_oauth_response(400,"No asset specified")
      else
        if @group.nil?
          invalid_oauth_response(404,"Unknown asset")
        else
          invalid_oauth_response(409,"Asset does not match token") if current_token.group_id != @group.id
        end
      end
    end
    true 
  end
end
