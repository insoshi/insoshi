class BidsController < ApplicationController
  before_filter :login_required, :only => [:new,:edit,:create,:update,:destroy]
  before_filter :setup

  # POST /bids
  # POST /bids.xml
  def create
    #@bid = Bid.new(params[:bid])
    @bid = @req.bids.new(params[:bid])
    @bid.person = current_person
    @bid.status_id = Bid::OFFERED
    if @bid.expiration_date.blank?
      @bid.expiration_date = 7.days.from_now
    else
      @bid.expiration_date += 1.day - 1.second # make expiration date at end of day
    end

    respond_to do |format|
      if @bid.save
        bid_note = Message.new()
        subject = "BID: " + @bid.estimated_hours.to_s + " hours - " + @req.name 
        bid_note.subject = subject.length > 75 ? subject.slice(0,75).concat("...") : subject
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
    case params[:aasm_event]
    when 'accept'
      if current_person?(@bid.req.person)
        @bid.accept!
        flash[:notice] = 'Bid accepted. Message sent to bidder to commit'
      end
    when 'commit'
      if current_person?(@bid.person)
        @bid.commit!
        flash[:notice] = 'Bid committed. Notification sent to requestor'
      end
    when 'complete'
      if current_person?(@bid.person)
        @bid.complete!
        flash[:notice] = 'Work marked completed. Notification sent to requestor'
      end
    when 'pay'
      if current_person?(@bid.req.person)
        @bid.pay!
        flash[:notice] = 'Work marked verified. Approval notification sent'
      end
    else
      logger.warn "Error.  Invalid bid event: #{params[:aasm_event]}"
      flash[:error] = "Invalid bidding event"
    end
    redirect_to @req
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

  def process_approval
    @bid.approved_at = Time.now
    @bid.status_id = Bid::SATISFIED

    if @bid.save!
    else
      # XXX handle error
    end
  end
end
