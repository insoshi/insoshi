class MessagesController < ApplicationController

  before_filter :login_required
  before_filter :authenticate_person, :only => [:show]

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
    @message.read if current_person == @message.recipient
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
    # TODO: refactor this mess
    @message = Message.new
    original_message = Message.find(params[:id])
    @message.parent_id = original_message.id
    sender = original_message.sender
    @recipient = sender == current_person ? original_message.recipient : sender
    respond_to do |format|
      format.html { render :action => "new" }
    end    
  end

  def create
    redirect_to messages_url and return if params[:commit] == "Cancel"
    @recipient = Person.find(params[:person_id])
    if @recipient == current_person
      flash[:error] = "You can't send messages to yourself"
      redirect_to home_url and return
    end
    redirect_to '/' and return if reply? and not valid_reply?
    
    @data = params[:message].merge(:sender    => current_person,
                                   :recipient => @recipient)
    @message = Message.new(@data)
    
    respond_to do |format|
      if @message.save
        flash[:success] = 'Message sent!'
        format.html { redirect_to messages_url }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def destroy
    @message = Message.find(params[:id])
    if @message.trash(current_person)
      flash[:success] = "Message deleted"
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
  
    def authenticate_person
      @message = Message.find(params[:id])
      unless (current_person == @message.sender or
              current_person == @message.recipient)
        redirect_to login_url
      end
    end
    
    def reply?
      !params[:parent_id].nil?
    end

    def valid_reply?
      original = Message.find(params[:parent_id])
      original.recipient == current_person and original.sender == @recipient
    end
end
