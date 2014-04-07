class BidsController < ApplicationController
  load_resource :req
  load_and_authorize_resource :bid, :through => :req
  before_filter :login_required
  before_filter :credit_card_required

  # POST /bids
  # POST /bids.xml
  def create
    @bid = @req.bids.new(params[:bid])
    @bid.person = current_person

    respond_to do |format|
      if @bid.save
        flash[:notice] = t('success_bid_created') 
        format.js
      else
        format.js { render :action => 'new' }
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
        flash[:notice] = t('notice_bid_accepted')
      end
    when 'commit'
      if current_person?(@bid.person)
        @bid.commit!
        flash[:notice] = t('notice_bid_committed')
      end
    when 'complete'
      if current_person?(@bid.person)
        @bid.complete!
        flash[:notice] = t('notice_bid_completed')
      end
    when 'pay'
      @bid.req.ability = current_ability
      if current_person?(@bid.req.person)
        @bid.pay!
        flash[:notice] = t('notice_bid_approved')
      end
    else
      logger.warn "Error.  Invalid bid event: #{params[:aasm_event]}"
      flash[:error] = t('notice_bid_invalid')
    end

    respond_to do |format|
      format.html { redirect_to @req }
      format.js
    end
  end

  # DELETE /bids/1
  # DELETE /bids/1.xml
  def destroy
    @bid = Bid.find(params[:id])
    @bid.destroy

    respond_to do |format|
      flash[:success] = t('notice_bid_removed')
      format.html { redirect_to req_url(@req) }
      format.js
      #format.xml  { head :ok }
    end
  end
end
