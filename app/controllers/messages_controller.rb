class MessagesController < ApplicationController

  before_filter :login_required, :setup
  before_filter :authenticate_person, :only => [:show]
  before_filter :handle_cancel, :only => [:create]
  before_filter :validate_reply, :only => [:create]

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

  def show
    @message.mark_as_read if current_person?(@message.recipient)
    respond_to do |format|
      format.html
    end
  end

  def new    
    @message = Message.new
    @recipient = Person.find(params[:person_id])

    respond_to do |format|
      format.html
    end
  end

  def reply
    original_message = Message.find(params[:id])
    @message = Message.new(:parent    => original_message,
                           :subject   => original_message.subject,
                           :sender    => current_person,
                           :recipient => original_message.sender)
    @recipient = not_current_person(original_message)
    respond_to do |format|
      format.html { render :action => "new" }
    end    
  end

  def create
    @message = Message.new(params[:message].merge(:sender => current_person,
                                                  :recipient => @recipient))
  
    respond_to do |format|
      if !preview? and @message.save
        flash[:success] = 'Message sent!'
        format.html { redirect_to messages_url }
      else
        @preview = @message.content if preview?
        format.html { render :action => "new" }
      end
    end
  end

  def destroy
    @message = Message.find(params[:id])
    if @message.trash(current_person)
      flash[:success] = "Message trashed"
    else
      # This should never happen...
      flash[:error] = "Invalid action"
    end
  
    respond_to do |format|
      format.html { redirect_to messages_url }
    end
  end
  
  def undestroy
    @message = Message.find(params[:id])
    if @message.untrash(current_person)
      flash[:success] = "Message restored to inbox"
    else
      # This should never happen...
      flash[:error] = "Invalid action"
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
    
    def validate_reply
      @recipient = Person.find(params[:person_id])
      redirect_to home_url if reply? and not valid_reply?(@recipient)
    end
    
    def reply?
      !params[:parent_id].nil?
    end

    def valid_reply?(recipient)
      original = Message.find(params[:parent_id])
      original.recipient == current_person and original.sender == recipient
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
