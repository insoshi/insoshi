class BidsController < ApplicationController
  before_filter :login_required, :only => [:new,:edit,:create,:update,:destroy]
  before_filter :setup

  # GET /bids
  # GET /bids.xml
  def index
    @bids = Bid.find(:all)

    respond_to do |format|
      format.html # index.html.erb
     # format.xml  { render :xml => @bids }
    end
  end

  # GET /bids/1
  # GET /bids/1.xml
  def show
    @bid = Bid.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
     # format.xml  { render :xml => @bid }
    end
  end

  # GET /bids/new
  # GET /bids/new.xml
=begin
  def new
    @bid = Bid.new

    respond_to do |format|
      format.html # new.html.erb
     # format.xml  { render :xml => @bid }
    end
  end
=end

=begin
  # GET /bids/1/edit
  def edit
    @bid = Bid.find(params[:id])
  end
=end

  # POST /bids
  # POST /bids.xml
  def create
    #@bid = Bid.new(params[:bid])
    @bid = @req.bids.new(params[:bid])
    @bid.person = current_person
    @bid.status_id = Bid::OFFERED

    respond_to do |format|
      if @bid.save
        bid_note = Message.new()
        bid_note.subject = "BID: " + @bid.estimated_hours.to_s + " hours - " + @req.name 
        bid_note.content = "See your <a href=\"" + req_path(@req) + "\">request</a> to consider bid"
        bid_note.sender = @bid.person
        bid_note.recipient = @req.person
        bid_note.save!

        flash[:notice] = 'Bid was successfully created.'
        format.html { redirect_to req_path(@req) }
        #format.xml  { render :xml => @bid, :status => :created, :location => @bid }
      else
        flash[:error] = 'Error creating bid.'
        format.html { redirect_to req_path(@req) }
        #format.xml  { render :xml => @bid.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bids/1
  # PUT /bids/1.xml
  def update
    @bid = Bid.find(params[:id])
    new_bid = params[:bid]
    status = new_bid[:status_id]
    if current_person?(@bid.req.person)
      # XXX so far, just doing accept
      @bid.accepted_at = Time.now
      @bid.status_id = status
    end

    respond_to do |format|
      if @bid.save!
        flash[:notice] = 'Bid was successfully updated.'
        bid_note = Message.new()
        bid_note.subject = "Bid accepted for " + @req.name # XXX make sure length does not exceed 40 chars
        bid_note.content = "See the <a href=\"" + req_path(@bid.req) + "\">request</a> to commit to bid"
        bid_note.sender = @bid.req.person
        bid_note.recipient = @bid.person
        bid_note.save!
        format.html { redirect_to(@bid.req) }
       # format.xml  { head :ok }
      else
        format.html { redirect_to(@bid.req) }
       # format.xml  { render :xml => @bid.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bids/1
  # DELETE /bids/1.xml
  def destroy
    @bid = Bid.find(params[:id])
    @bid.destroy

    respond_to do |format|
      flash[:success] = 'Bid was removed.'
      format.html { redirect_to req_url(@req) }
      #format.xml  { head :ok }
    end
  end

  private

  def setup
    @req = Req.find(params[:req_id])
    @body = "req"
  end
end
