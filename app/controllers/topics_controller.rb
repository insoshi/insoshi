class TopicsController < ApplicationController
  
  before_filter :login_required
  before_filter :admin_required, :only => [:edit, :update, :destroy]
  before_filter :setup
  
  def index
    redirect_to forum_url(params[:forum_id])
  end

  def show
    @topic = Topic.find(params[:id])
    @posts = @topic.posts
    
    respond_to do |format|
      format.html
      format.atom
    end
  end

  def new
    @topic = Topic.new

    respond_to do |format|
      format.html
    end
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def create
    @topic = @forum.topics.new(params[:topic])
    @topic.person = current_person

    respond_to do |format|
      if @topic.save
        flash[:success] = 'Topic was successfully created.'
        format.html { redirect_to forum_topic_path(@forum, @topic) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @topic = Topic.find(params[:id])

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        flash[:success] = 'Topic was successfully updated.'
        format.html { redirect_to forum_url(@forum) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy

    respond_to do |format|
      flash[:success] = 'Topic was successfully destroyed.'
      format.html { redirect_to forum_url(@forum) }
    end
  end

  private
  
    def setup
      @forum = Forum.find(params[:forum_id])
      @body = "forum"
    end
end
