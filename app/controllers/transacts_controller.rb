class TransactsController < ApplicationController
  skip_before_filter :require_activation
  before_filter :login_or_oauth_required

  def index
    @transactions = current_person.transactions
    respond_to do |format|
      format.xml { render :xml => @transactions.to_xml(:root => "txns") }
      format.json { render :json => @transactions.to_json }
    end
  end

  def new
    @swp = params[:to] && params[:amount]

    @req = Req.new()
    @req.name = params[:memo]
    @transact = Transact.new(:to => params[:to], :amount => params[:amount], :callback_url => params[:callback_url], :redirect_url => params[:redirect_url])
    if @swp
      @worker = Person.find_by_email(@transact.to)
    end
  end

  def create
    @transact = Transact.new(params[:transact])
    @transact.customer = current_person

    @worker = Person.find_by_email(@transact.to)
    if nil == @worker
      flash[:error] = "could not find payee"
      render :action => "new"
      return
    end
    
    @transact.worker = @worker

    @req = Req.new(params[:req])
    @transact.save_req(@req)

    if @transact.save
      if @transact.redirect_url.blank?
        flash[:notice] = "Transfer succeeded."
        redirect_to person_path(@worker) and return
      else
        @transact.redirect_url << "?status=ok"
        redirect_to @transact.redirect_url
      end
    else
      flash[:error] = "Error with transfer."
      req_name = @req.name
      @req.destroy
      @req = Req.new
      @req.name = req_name
      render :action => "new"
    end

  end

end
