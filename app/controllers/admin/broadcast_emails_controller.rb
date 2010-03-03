class Admin::BroadcastEmailsController < ApplicationController
  before_filter :login_required
  before_filter :correct_person_required

  # GET /admin_broadcast_emails
  # GET /admin_broadcast_emails.xml
  def index
    @broadcast_emails = BroadcastEmail.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_broadcast_emails }
    end
  end

  # GET /admin_broadcast_emails/1
  # GET /admin_broadcast_emails/1.xml
  def show
    @broadcast_email = BroadcastEmail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @broadcast_email }
    end
  end

  # GET /admin_broadcast_emails/new
  # GET /admin_broadcast_emails/new.xml
  def new
    @body = "yui-skin-sam"
    @broadcast_email = BroadcastEmail.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @broadcast_email }
    end
  end

  # GET /admin_broadcast_emails/1/edit
  def edit
    @body = "yui-skin-sam"
    @broadcast_email = BroadcastEmail.find(params[:id])
  end

  # POST /admin_broadcast_emails
  # POST /admin_broadcast_emails.xml
  def create
    @broadcast_email = BroadcastEmail.new(params[:broadcast_email])

    respond_to do |format|
      if @broadcast_email.save
        flash[:notice] = 'Admin::BroadcastEmail was successfully created.'
#        MailingsWorker.async_send_mailing(:mailing_id => @broadcast_email.id)
        Cheepnis.enqueue(@broadcast_email)

        format.html { redirect_to(admin_broadcast_email_path(@broadcast_email)) }
        format.xml  { render :xml => @broadcast_email, :status => :created, :location => @broadcast_email }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @broadcast_email.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_broadcast_emails/1
  # PUT /admin_broadcast_emails/1.xml
  def update
    @broadcast_email = BroadcastEmail.find(params[:id])

    respond_to do |format|
      if @broadcast_email.update_attributes(params[:broadcast_email])
        flash[:notice] = 'Admin::BroadcastEmail was successfully updated.'
        format.html { redirect_to(admin_broadcast_email_path(@broadcast_email)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @broadcast_email.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_broadcast_emails/1
  # DELETE /admin_broadcast_emails/1.xml
  def destroy
    @broadcast_email = BroadcastEmail.find(params[:id])
    @broadcast_email.destroy

    respond_to do |format|
      format.html { redirect_to(admin_broadcast_emails_url) }
      format.xml  { head :ok }
    end
  end

private

  def correct_person_required
    redirect_to home_url unless current_person.admin?
  end
end
