class PostsController < ApplicationController
  
  before_filter :login_required
  before_filter :get_instance_vars

  def index
    if forum?
      @posts = @topic.posts
    elsif blog?
      @posts = @blog.posts.paginate(:page => params[:page])
    end

    respond_to do |format|
      format.html do
        render :action => "forum_index" if forum?
        render :action => "blog_index" if blog?
      end
    end
  end

  def show
    @post = model.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @post = model.new

    respond_to do |format|
      format.html do
        render :action => "forum_new" if forum?
        render :action => "blog_new"  if blog?
      end
    end
  end

  def edit
    @post = model.find(params[:id])
    # TODO: Switch on forum/blog
  end

  def create
    if forum?
      @post = @topic.posts.new(params[:post].merge(:person => current_person))
    elsif blog?
      @post = @blog.posts.new(params[:post])
    end
    
    respond_to do |format|
      if @post.save
        flash[:success] = 'Post was successfully created.'
        format.html { redirect_to posts_url }
      else
        format.html do
          render :action => "forum_new" if forum?
          render :action => "blog_new"  if blog?
        end
      end
    end
  end

  def update
    @post = model.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:success] = 'Post was successfully updated.'
        format.html { redirect_to posts_url }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @post = model.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
    end
  end
  
  private
  
    def get_instance_vars
      if forum?
        @forum = Forum.find(params[:forum_id])
        @topic = Topic.find(params[:topic_id])
      elsif blog?
        @blog = Blog.find(params[:blog_id])
      end
    end
    
    # Handle forum and blog posts in a uniform manner.
    
    def model
      if forum?
        ForumPost
      elsif blog?
        BlogPost
      end
    end
    
    def posts_url
      if forum?
        forum_topic_url(@forum, @topic)
      elsif blog?
        blog_posts_url(@blog)
      end
    end
    
    def forum?
      !params[:forum_id].nil?
    end
    
    def blog?
      !params[:blog_id].nil?
    end
end
