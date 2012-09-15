class TransactsController < ApplicationController
  skip_before_filter :require_activation
  prepend_before_filter :activate_authlogic
  oauthenticate :strategies => :token, :except => [:about_user,:wallet,:scopes,:new]
  oauthenticate :strategies => [], :only => :new
  oauthenticate :strategies => :token, :interactive => false, :only => [:about_user,:wallet,:scopes]
  before_filter :find_group_by_asset, :except => [:about_user,:user_info,:wallet,:scopes]
  skip_before_filter :verify_authenticity_token, :set_person_locale, :if => :oauth?

  def about_user
    @person = {'login' => current_person.to_param,
               'email_md5' => Digest::MD5.hexdigest(current_person.email),
               'profile' => person_url(current_person),
               'thumbnail_url' => current_person.thumbnail}
    respond_to do |format|
      format.json { render :json => @person.as_json }
    end
  end

  def user_info
    @user_info = {'name' => current_person.display_name,
                  'profile' => person_url(current_person),
                  'picture' => current_person.thumbnail,
                  'website' => current_person.openid_identifier || '',
                  'email' => current_person.email,
                  'user_id' => current_person.id.to_s}
    respond_to do |format|
      format.json { render :json => @user_info.as_json }
    end
  end

  def wallet
    unless includes_wallet_capability?
      return invalid_oauth_response(401,"Bad scope")
    end
    @groups = current_person.groups.select {|g| g.opentransact?}
    @assets = @groups.map {|g| {:name => g.asset, :url => transacts_url(:asset => g.asset), :balance => current_person.account(g).balance_with_initial_offset.to_s}}
    @wallet = {'version' => '1.0',
                'encoding' => 'UTF8',
                'total' => @assets.length,
                'assets' => @assets}
    respond_to do |format|
      format.json { render :json => @wallet.as_json }
    end
  end

  def index
    if oauth?
      unless includes_list_capability?
        return invalid_oauth_response(401,"Bad scope")
      end
    end
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
    if oauth?
      # Make sure scope is good for the asset
      unless includes_payment_capability?
        return invalid_oauth_response(401,"Bad scope")
      end
    end

    # Transact.to and Transact.memo - makes @transact look opentransacty
    #
    @transact = Transact.new(:to => params[:to], :memo => params[:note], :amount => params[:amount], :callback_url => params[:callback_url], :redirect_url => params[:redirect_url])

    @worker = opentransact_find_worker(params[:to])
    if nil == @worker
      respond_to do |format|
        format.html do
          flash[:error] = t('error_could_not_find_payee')
          render :action => "new"
        end
        format.json do
          @transact.errors.add(:base, t('error_could_not_find_payee'))
          render :json => @transact.as_json, :status => :unprocessable_entity
        end
      end
      return
    end

    @transact.customer = current_person
    @transact.worker = @worker
    @transact.group = @group

    @transact.metadata = @transact.create_req(params[:note])

    if can?(:create, @transact) && @transact.save
      if current_token && (cap = current_token.single_payment?)
        cap.invalidate!
      end
      if @transact.redirect_url.blank?
        respond_to do |format|
          format.html do 
            flash[:notice] = t('notice_transfer_succeeded')
            redirect_to person_path(@worker)
          end
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

  def scopes
    result = ""
    scopes = []

    if oauth?
      current_token.capabilities.each do |capability|
        scopes << capability.scope unless capability.invalidated?
      end
      result = scopes.join(" ")
    end

    respond_to do |format|
      format.html { render :text => result }
      format.json { render :json => scopes.as_json }
    end
  end

  private

  def opentransact_find_worker(payee)
    # assume identifier is either an email address or a url
    if payee.split('@').size == 2
      @worker = Person.find_by_email(payee)
    else
      @worker = Person.find_by_openid_identifier(OpenIdAuthentication.normalize_identifier(CGI.unescape(payee)))
    end
  end

  def includes_wallet_capability?
    current_token.capabilities.detect {|c| c.can_list_wallet_contents? }
  end

  def includes_list_capability?
    current_token.capabilities.detect {|c| c.can_list?(@group)}
  end

  def includes_payment_capability?
    current_token.capabilities.detect {|c| c.can_pay?(@group)}
  end

  def find_group_by_asset
    @group = Group.by_opentransact(params[:asset])
    if oauth?
      unless params[:asset]
        invalid_oauth_response(400,"No asset specified")
      else
        if @group.nil?
          invalid_oauth_response(404,"Unknown asset")
        end
      end
    end
    true 
  end
end
