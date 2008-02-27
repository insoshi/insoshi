class TopicsController < ApplicationController
  
  before_filter :login_required, :except => [:index, :show]
  before_filter :get_forum
  
  def index
    @topics = @forum.topics.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    @topic = Topic.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def create
    @topic = @forum.topics.new(params[:topic].merge(:person => current_person))

    respond_to do |format|
      if @topic.save
        flash[:success] = 'Topic was successfully created.'
        format.html { redirect_to forum_topic_posts_path(@forum, @topic) }
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
        format.html { redirect_to forum_url }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to forum_url }
    end
  end

  private
  
    def get_forum
      # There is currently only one forum.
      @forum = Forum.find(:first)
    end
end
