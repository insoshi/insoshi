class MessagesController < ApplicationController

  before_filter :login_required, :setup
  before_filter :authenticate_person, :only => :show
  before_filter :handle_cancel, :only => :create

  # GET /messages
  def index
    @messages = current_person.received_messages(params[:page])
    respond_to do |format|
      format.html { render :template => "messages/index" }
    end
  end

  # GET /messages/sent
  def sent
    @messages = current_person.sent_messages(params[:page])
    respond_to do |format|
      format.html { render :template => "messages/index" }
    end
  end
  
  # GET /messages/trash
  def trash
    @messages = current_person.trashed_messages(params[:page])
    respond_to do |format|
      format.html { render :template => "messages/index" }
    end    
  end

  # GET /messages/recipients
  # Used to autocomplete recipient name in messages
  def recipients
    unless params[:term].blank? || params[:term].length < 2
      @recipients = Person.select('id, name').where("lower(name) like ?", "#{params[:term].downcase}%").limit(params[:limit] || 50)
    else
      @recipients = []
    end
    respond_to do |format|
      format.json { render :json => @recipients.collect{|p| p.as_json(:methods => [:icon,:to_param], :only=>[:id, :name, :icon])} }
    end 
  end

  def show
    @message.mark_as_read if current_person?(@message.recipient)
    respond_to do |format|
      format.html
    end
  end

  def new    
    @message = Message.new
    @recipient = Person.find(params[:person_id]) if params[:person_id]

    respond_to do |format|
      format.html
      format.js
    end
  end

  def reply
    original_message = Message.find(params[:id])
    recipient = original_message.other_person(current_person)
    @message = Message.unsafe_build(:parent_id    => original_message.id,
                                    :subject      => original_message.subject,
                                    :sender       => current_person,
                                    :recipient    => recipient)

    @recipient = not_current_person(original_message)
    respond_to do |format|
      format.html { render :action => "new" }
    end    
  end

  def create
    @message = Message.new(params[:message])
    @recipient = Person.find(params[:person_id]) if params[:person_id]
    @message.sender    = current_person
    @message.recipient = @recipient
    if reply?
      @message.parent = Message.find(params[:message][:parent_id])
      redirect_to home_url and return unless @message.valid_reply?
    end
  
    respond_to do |format|
      if !preview? and @message.save
        flash[:notice] = t('success_message_sent') 
        format.html { redirect_to messages_url }
        format.js
      else
        @preview = @message.content if preview?
        format.html { render :action => "new" }
        format.js { render :action => "new" }
      end
    end
  end

  def destroy
    @message = Message.find(params[:id])
    if @message.trash(current_person)
      flash[:success] = t('success_message_trashed')
    else
      # This should never happen...
      flash[:error] =  t('error_invalid_action')
    end
  
    respond_to do |format|
      format.html { redirect_to messages_url }
    end
  end
  
  def undestroy
    @message = Message.find(params[:id])
    if @message.untrash(current_person)
      flash[:success] = t('success_message_restored_to_inbox')
    else
      # This should never happen...
      flash[:error] = t('error_invalid_action')
    end
    respond_to do |format|
      format.html { redirect_to messages_url }
    end
  end

  private
  
    def setup
      @body = "messages"
    end
  
    def authenticate_person
      @message = Message.find(params[:id])
      unless (current_person == @message.sender or
              current_person == @message.recipient)
        redirect_to login_url
      end
    end

    def handle_cancel
      redirect_to messages_url if params[:commit] == "Cancel"
    end
        
    def reply?
      not params[:message][:parent_id].nil?
    end
    
    # Return the proper recipient for a message.
    # This should not be the current person in order to allow multiple replies
    # to the same message.
    def not_current_person(message)
      message.sender == current_person ? message.recipient : message.sender
    end

    def preview?
      params["commit"] == "Preview"
    end

end
