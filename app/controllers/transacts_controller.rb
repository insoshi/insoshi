class TransactsController < ApplicationController
  skip_before_filter :require_activation
  before_filter :login_or_oauth_required
  skip_before_filter :verify_authenticity_token, :if => :oauth?

  def index
    @transactions = current_person.transactions
    respond_to do |format|
      format.html
      format.xml { render :xml => @transactions.to_xml(:root => "txns") }
      format.json { render :json => @transactions.to_json }
    end
  end

  def show
    @transact = current_person.transactions.find(params[:id])
    if nil == @transact
        flash[:error] = "could not find transaction"
        redirect_to home_url
        return
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => @transact.to_xml }
      format.json { render :json => @transact.to_json }
    end
  end

  def new
    @swp = params[:to] && params[:amount]
    if @swp
      @worker = Person.find_by_email(params[:to])
      if nil == @worker
        @swp = false
        flash[:error] = "could not find payee"
        render :action => "new"
        return
      end
    end
  end

  def create
    @worker = Person.find_by_email(params[:to])
    if nil == @worker
      @swp = false
      flash[:error] = "could not find payee"
      render :action => "new"
      return
    end

    # Transact.to and Transact.memo - makes @transact look opentransacty
    #
    @transact = Transact.new(:to => params[:to], :memo => params[:memo], :amount => params[:amount], :callback_url => params[:callback_url], :redirect_url => params[:redirect_url])
    @transact.customer = current_person
    @transact.worker = @worker

    @transact.metadata = @transact.create_req(params[:memo])

    if @transact.save
      if @transact.redirect_url.blank?
        flash[:notice] = "Transfer succeeded."
        respond_to do |format|
          format.html { redirect_to person_path(@worker) }
          format.json { render :json => @transact.to_json }
          format.xml { render :xml => @transact.to_xml }
        end
      else
        @transact.redirect_url << "?status=ok"
        redirect_to @transact.redirect_url
      end
    else
      flash[:error] = "Error with transfer."
      @req.destroy
      render :action => "new"
    end

  end

end
