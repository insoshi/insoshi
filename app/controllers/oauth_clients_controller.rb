class OauthClientsController < ApplicationController
  before_filter :login_required, :except => [:create]
  before_filter :get_client_application, :only => [:show, :edit, :update, :destroy]
 
  def index
    @client_applications = current_person.client_applications
    @tokens = current_person.tokens.find :all, :conditions => 'oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null'
  end

  def new
    @client_application = ClientApplication.new
  end

  def create
    respond_to do |format|
      format.html do
        if current_person
          @client_application = current_person.client_applications.build(params[:client_application])
          if @client_application.save
            flash[:notice] = t('notice_registered_the_information_successfully')
            redirect_to :action => "show", :id => @client_application.id
          else
            render :action => "new"
          end
        end
      end
      format.json do
        response.headers["Cache-Control"] = "private, no-store, max-age=0, must-revalidate"
        redirect_uri = ""
        begin
          raise "client_name" if params[:client_name].nil?
          raise "client_url" if params[:client_url].nil?
          raise "client_description" if params[:client_description].nil?
          raise "type" if params[:type].nil?

          if params[:application_type] && 'noredirect' == params[:application_type]
            redirect_uri = request.protocol + request.host_with_port + "/transacts"
          elsif params[:redirect_url]
            redirect_uri = params[:redirect_url]
          end
          @client_application = ClientApplication.new :name => params[:client_name], :description => params[:client_description], :url => params[:client_url], :callback_url => redirect_uri, :person => nil
          if @client_application.save!
            render :json => @client_application.as_json
          else
            render :json => {:error => "Bad Request"}.as_json, :status => 400
          end
        rescue => e
          render :json => {:error => "Missing parameter: #{e}"}.as_json, :status => 400
        end
      end
    end
  end
  
  def show
  end

  def edit
  end
  
  def update
    if @client_application.update_attributes(params[:client_application])
      flash[:notice] = t('notice_updated_the_client_information_successfully')
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "edit"
    end
  end

  def destroy
    @client_application.destroy
    flash[:notice] = t('notice_destroyed_the_client_application_registration')
    redirect_to :action => "index"
  end
  
  private
  def get_client_application
    unless @client_application = current_person.client_applications.find(params[:id])
      flash.now[:error] = t('error_wrong_application_id')
      raise ActiveRecord::RecordNotFound
    end
  end
end
