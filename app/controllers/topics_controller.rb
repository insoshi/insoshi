class TopicsController < ApplicationController
  
  before_filter :login_required
  before_filter :admin_required, :only => [:edit, :update, :destroy]
  before_filter :setup
  
  def index
    redirect_to forum_url(params[:forum_id])
  end

  def show
    @group = @forum.group
    @topic = Topic.find(params[:id])
    @posts = @topic.posts.paginate(:page => params[:page], :per_page => 2)
    respond_to do |format|
      format.html
      format.js
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
    @body = "yui-skin-sam" 
    @topic = @forum.topics.new(params[:topic])
    @topic.person = current_person

    respond_to do |format|
      if @topic.save
        flash[:notice] = t('success_topic_created')
#        format.html { redirect_to forum_topic_path(@forum, @topic) }
        format.js
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @topic = Topic.find(params[:id])

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        flash[:notice] = t('notice_topic_updated')
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
      flash[:success] = t('success_topic_destroyed')
      format.html { redirect_to forum_url(@forum) }
    end
  end

  private
  
    def setup
      @forum = Forum.find(params[:forum_id])
      @body = "forum"
      @body = "yui-skin-sam "
    end
end
