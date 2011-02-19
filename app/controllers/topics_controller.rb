class TopicsController < ApplicationController
  load_resource :forum
  
  before_filter :login_required
  
  def index
    redirect_to forum_url(params[:forum_id])
  end

  def show
    @group = @forum.group
    @topic = Topic.find(params[:id])
    @posts = @topic.posts.paginate(:page => params[:page], :per_page => AJAX_POSTS_PER_PAGE)
    respond_to do |format|
      format.html
      format.js do
        @refresh_milliseconds = global_prefs.topic_refresh_seconds * 1000
      end
    end
  end

  def new
    @topic = Topic.new

    respond_to do |format|
      format.html
    end
  end

  def create
    @body = "yui-skin-sam" 
    @topic = @forum.topics.new(params[:topic])
    @topic.person = current_person

    respond_to do |format|
      if @topic.save
        flash[:notice] = t('success_topic_created')
        format.html { redirect_to forum_topic_path(@forum, @topic) }
        format.js
      else
        format.html { render :action => "new" }
      end
    end
  end

  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy
    @topics = Topic.find_recently_active(@forum, params[:page]) 

    respond_to do |format|
      flash[:notice] = t('success_topic_destroyed')
      format.js
    end
  end
end
