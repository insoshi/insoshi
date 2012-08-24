class PostsController < ApplicationController
  include ApplicationHelper
  
  before_filter :login_required
  before_filter :get_instance_vars

  def index
    respond_to do |format|
      format.js do
        seconds = global_prefs.topic_refresh_seconds
        @refresh_milliseconds = seconds * 1000
        @topic.update_viewer(current_person)
        # Exclude your own to avoid picking up the one you just posted
        @posts = @topic.posts_since_last_refresh(params[:after].to_i, current_person.id)
        @viewers = @topic.current_viewers(seconds * 2)
      end
      format.html { redirect_to forum_topic_url(@forum, @topic) }
    end
  end

  # Forum posts don't get shown individually.
  # def show
  # end

  def new
    @post = model.new

    respond_to do |format|
      format.html { render :action => "forum_new" }
    end
  end

  def edit
    respond_to do |format|
      format.html { render :action => "forum_edit" }
    end
  end

  def create
    @post = @topic.posts.build(params[:post])
    @post.person = current_person
    authorize! :create, @post

    respond_to do |format|
      if @post.save
        flash[:success] = t('success_post_created')
        format.html { redirect_to forum_topic_url(@forum, @topic, :posts => @topic.posts.count) }
        format.js
      else
        format.html { render :action => "forum_new" }
        format.js {render :action => 'new'}
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = t('notice_post_updated')
        format.html { redirect_to forum_topic_url(@forum, @topic, :posts => @topic.posts.count) }
      else
        format.html { render :action => "forum_edit" }
      end
    end
  end

  def destroy
    @post = model.find(params[:id])
    authorize! :destroy, @post
    @post.destroy
    flash[:notice] = t('success_post_destroyed')

    respond_to do |format|
      format.html { redirect_to forum_topic_url(@forum, @topic) }
      format.js
    end
  end
  
  private
  
    ## Before filters
  
    def get_instance_vars
      @post = ForumPost.find(params[:id]) unless params[:id].nil?
      @topic = Topic.find(params[:topic_id])
      @forum = @topic.forum
      @body = "forum"
    end

    # Return the posts array for the given resource.
    def resource_posts
      @topic.posts
    end

end
