# NOTE: We use "posts" for both forum topic posts and blog posts,
# There is some trickery to handle the two in a unified manner.
class PostsController < ApplicationController
  
  before_filter :login_required
  before_filter :get_instance_vars
  before_filter :authorize_edit, :only => [:edit, :update]
  before_filter :authorize_destroy, :only => [:destroy]

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
    respond_to do |format|
      format.html { render :action => resource_template("edit") }
    end
  end

  # Used for both forum and blog posts.
  def create
    @post = new_resource_post
    
    respond_to do |format|
      if @post.save
        flash[:success] = 'Post created'
        format.html { redirect_to post_url }
      else
        format.html { render :action => resource_template("new") }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:success] = 'Post updated'
        format.html { redirect_to post_url }
      else
        format.html { render :action => resource_template("edit") }
      end
    end
  end

  def destroy
    @post = model.find(params[:id])
    @post.destroy
    flash[:success] = "Post destroyed"

    respond_to do |format|
      format.html { redirect_to posts_url }
    end
  end
  
  private
  
    ## Before filters
  
    def get_instance_vars
      @post = model.find(params[:id]) unless params[:id].nil?
      if forum?
        @forum = Forum.find(:first)
        @topic = Topic.find(params[:topic_id])
      elsif blog?
        @blog = Blog.find(params[:blog_id])
      end
    end

    # Make sure the current user is authorized to edit this post
    def authorize_edit
      if forum?
        redirect_to home_url unless current_person?(@post.person)
      elsif blog?
        redirect_to home_url unless (current_person?(@blog.person) and
                                     current_blog?(@post.blog))
      end
    end
    
    def current_blog?(blog)
      blog == @blog
    end
    
    # Authorize post deletions.
    # Only admin users can destroy forum posts.
    # Only blog owners can destroy blog posts.
    def authorize_destroy
      if forum?
        redirect_to home_url unless current_person.admin?
      elsif blog?
        authorize_edit
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
    def post_url
      if forum?
        forum_topic_posts_url(@forum, @topic)
      elsif blog?
        blog_post_url(@blog, @post)
      end
    end
    
    def posts_url
      if forum?
        forum_topic_posts_url(@forum, @topic)
      elsif blog?
        blog_posts_url(@blog)
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
