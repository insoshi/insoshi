# NOTE: We use "posts" for both forum topic posts and blog posts,
# There is some trickery to handle the two in a unified manner.
class PostsController < ApplicationController
  
  before_filter :login_required
  before_filter :get_instance_vars

  # Used for both forum and blog posts.
  def index
    @posts = resource_posts

    respond_to do |format|
      format.html { render :action => resource_template("index") }
    end
  end

  # This is only used for blog posts.
  def show
    @post = BlogPost.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # Used for both forum and blog posts.
  def new
    @post = model.new

    respond_to do |format|
      format.html { render :action => resource_template("new") }
    end
  end

  # Used for both forum and blog posts.
  def edit
    @post = model.find(params[:id])
    
    respond_to do |format|
      format.html { render :action => resource_template("edit") }
    end
  end

  # Used for both forum and blog posts.
  def create
    @post = new_resource_post
    
    respond_to do |format|
      if @post.save
        flash[:success] = 'Post was successfully created.'
        format.html { redirect_to posts_url }
      else
        format.html { render :action => resource_template("new") }
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
        format.html { render :action => resource_template("edit") }
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
        @forum = Forum.find(:first)
        @topic = Topic.find(params[:topic_id])
      elsif blog?
        @blog = Blog.find(params[:blog_id])
      end
    end
    
    ## Handle forum and blog posts in a uniform manner.
    
    # Return the appropriate model corresponding to the type of post.
    def model
      if forum?
        ForumPost
      elsif blog?
        BlogPost
      end
    end
    
    # Return the posts array for the given resource.
    def resource_posts
      if forum?
        @topic.posts
      elsif blog?
        @blog.posts.paginate(:page => params[:page])
      end  
    end
    
    # Return a new post for the given resource.
    def new_resource_post
      if forum?
        @post = @topic.posts.new(params[:post].merge(:person => current_person))
      elsif blog?
        @post = @blog.posts.new(params[:post])
      end      
    end
    
    # Return the template for the current resource given the name.
    # For example, on a blog resource_template("new") gives "blog_new"
    def resource_template(name)
      "#{resource}_#{name}"
    end

    # Return a string for the resource.
    def resource
      if forum?
        "forum"
      elsif blog?
        "blog"
      end
    end
    
    # Return the URL for the resource posts.
    def posts_url
      if forum?
        forum_topic_posts_url(@forum, @topic)
      elsif blog?
        blog_posts_url
      end
    end

    # True if resource lives in a discussion forum.
    # We reserve the right to suppress forum_id since there's only one forum,
    # so use topic_id to tell that it's a forum.
    def forum?
      !params[:topic_id].nil?
    end

    # True if resource lives in a blog.
    def blog?
      !params[:blog_id].nil?
    end
end
