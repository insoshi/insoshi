class ReqsController < ApplicationController
  skip_before_filter :require_activation, :only => [:show, :index]
  before_filter :login_required, :except => [:show, :index]
  before_filter :login_or_oauth_required, :only => [:show, :index]
  before_filter :correct_person_and_no_accept_required, :only => [ :edit, :update ]
  before_filter :correct_person_and_no_commitment_required, :only => [ :destroy ]
  before_filter :twitter_oauth_setup, :only => [:twitter_oauth_client, :twitter_oauth_callback]

  def twitter_oauth_client
    @request_token = @consumer.get_request_token
    session[:req_token] = @request_token.token
    session[:req_token_secret] = @request_token.secret
    redirect_to @request_token.authorize_url
    return
  end

  def twitter_oauth_callback
    require 'json'
    @request_token = OAuth::RequestToken.new(@consumer,session[:req_token],session[:req_token_secret])
    @access_token = @request_token.get_access_token
    @resp = @consumer.request(:get, '/account/verify_credentials.json', @access_token, {:scheme => :query_string})
    case @resp
    when Net::HTTPSuccess
      user_info = JSON.parse(@resp.body)
      unless user_info['screen_name']
        flash[:error] = "Authentication failed"
        redirect_to :action => :index
        return
      end

      changed = update_screen_name( user_info['screen_name'] )
      if changed
        system_twitter = global_prefs.twitter_name
        response = @access_token.post("/friendships/create/#{system_twitter}.json","")
        case response 
        when Net::HTTPSuccess
          follow(user_info['screen_name'])
          flash[:notice] = "You are following requests on Twitter!" 
          redirect_to :action => :index
        else
          flash[:error] = "Authentication failed"
          redirect_to :action => :index
        end
        return
      end

    else
        flash[:error] = "Authentication failed"
        redirect_to :action => :index
        return
    end

  end

  # GET /reqs
  # GET /reqs.xml
  def index
    @reqs = Req.current_and_active

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reqs }
    end
  end

  # GET /reqs/1
  # GET /reqs/1.xml
  def show
    @req = Req.find(params[:id])
    @bid = Bid.new
    @bid.estimated_hours = @req.estimated_hours

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @req }
    end
  end

  # GET /reqs/new
  # GET /reqs/new.xml
  def new
    @req = Req.new
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @req }
    end
  end

  # GET /reqs/1/edit
  def edit
    @req = Req.find(params[:id])
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
  end

  # POST /reqs
  # POST /reqs.xml
  def create
    @req = Req.new(params[:req])

    if @req.due_date.blank?
      @req.due_date = 7.days.from_now
    else
      @req.due_date += 1.day - 1.second # make due date at end of day
    end
    @req.person_id = current_person.id

    respond_to do |format|
      if @req.save
        flash[:notice] = 'Request was successfully created.'
        unless global_prefs.twitter_name.blank?
          @req.tweet(req_url(@req))
        end
        format.html { redirect_to(@req) }
        format.xml  { render :xml => @req, :status => :created, :location => @req }
      else
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        format.html { render :action => "new" }
        format.xml  { render :xml => @req.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reqs/1
  # PUT /reqs/1.xml
  def update
    @req = Req.find(params[:id])

#    @req.person_id = current_person.id

    respond_to do |format|
      if @req.update_attributes(params[:req])
        flash[:notice] = 'Request was successfully updated.'
        format.html { redirect_to(@req) }
        format.xml  { head :ok }
      else
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        format.html { render :action => "edit" }
        format.xml  { render :xml => @req.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reqs/1
  # DELETE /reqs/1.xml
  def destroy
    @req = Req.find(params[:id])
    @req.destroy

    respond_to do |format|
      format.html { redirect_to(reqs_url) }
      format.xml  { head :ok }
    end
  end 

  private

  def update_screen_name(screen_name)
    changed = false

    if current_person.twitter_name.blank?
      current_person.twitter_name = screen_name
      current_person.save!
      flash[:notice] = "Your Twitter name has been set to #{screen_name}"
      changed = true
    else
      if current_person.twitter_name != screen_name
        current_person.twitter_name = screen_name
        current_person.save!
        logger.info "#{current_person.name} changing twitter from #{current_person.twitter_name} to #{screen_name}"
        flash[:notice] = "Your Twitter has been changed from #{current_person.twitter_name} to #{screen_name}"
        changed = true
      end
    end

    changed
  end
  
  def twitter_oauth_setup
    require 'oauth'
    require 'oauth/consumer'
    @consumer_key = global_prefs.twitter_oauth_consumer_key
    @consumer_secret = global_prefs.plaintext_twitter_oauth_consumer_secret
    @consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, { :site => "http://twitter.com" })
  end

  def follow(twitter_id)
    twitter_name = global_prefs.twitter_name
    twitter_password = global_prefs.plaintext_twitter_password
    twitter_api = global_prefs.twitter_api

    twit = Twitter::Base.new(twitter_name,twitter_password, :api_host => twitter_api )
    begin
      twit.create_friendship(twitter_id)
    rescue Twitter::CantConnect => e
      logger.info "ERROR Twitter::CantConnect for [#{twitter_id}] (" + e.to_s + ")"
    end
  end

  def correct_person_and_no_accept_required
    request = Req.find(params[:id])
    redirect_to home_url unless request.person == current_person
    redirect_to home_url if request.has_accepted_bid?
  end

  def correct_person_and_no_commitment_required
    request = Req.find(params[:id])
    redirect_to home_url unless request.person == current_person
    redirect_to home_url if request.has_commitment? || request.has_approved?
  end
end
