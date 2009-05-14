class BidsController < ApplicationController
  before_filter :login_required, :only => [:new,:edit,:create,:update,:destroy]
  before_filter :setup

  # POST /bids
  # POST /bids.xml
  def create
    @bid = @req.bids.new(params[:bid])
    @bid.person = current_person

    respond_to do |format|
      if @bid.save
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
end
