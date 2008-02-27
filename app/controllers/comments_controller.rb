# NOTE: We use "comments" for both wall topic comments and blog comments,
# There is some trickery to handle the two in a unified manner.
class CommentsController < ApplicationController
  
  before_filter :login_required
  before_filter :get_instance_vars

  # Used for both wall and blog comments.
  def index
    @comments = resource_comments

    respond_to do |format|
      format.html { render :action => resource_template("index") }
    end
  end

  # This is only used for blog comments.
  def show
    @comment = BlogPostComment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # Used for both wall and blog comments.
  def new
    @comment = model.new

    respond_to do |format|
      format.html { render :action => resource_template("new") }
    end
  end

  # Used for both wall and blog comments.
  def edit
    @comment = model.find(params[:id])
    
    respond_to do |format|
      format.html { render :action => resource_template("edit") }
    end
  end

  # Used for both wall and blog comments.
  def create
    @comment = new_resource_comment
    
    respond_to do |format|
      if @comment.save
        flash[:success] = 'Comment was successfully created.'
        format.html { redirect_to comments_url }
      else
        format.html { render :action => resource_template("new") }
      end
    end
  end

  def update
    @comment = model.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:success] = 'Comment was successfully updated.'
        format.html { redirect_to comments_url }
      else
        format.html { render :action => resource_template("edit") }
      end
    end
  end

  def destroy
    @comment = model.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to comments_url }
    end
  end
  
  private
  
    def get_instance_vars
      if wall?
        @wall = Wall.find(params[:wall_id])
      elsif blog?
        @blog = Blog.find(params[:blog_id])
        @post = Post.find(params[:post_id])
      end
    end
    
    ## Handle wall and blog comments in a uniform manner.
    
    # Return the appropriate model corresponding to the type of comment.
    def model
      if wall?
        WallComment
      elsif blog?
        BlogPostComment
      end
    end
    
    # Return the comments array for the given resource.
    def resource_comments
      if wall?
        @wall.comments
      elsif blog?
        @post.comments.paginate(:page => params[:page])
      end  
    end
    
    # Return a new comment for the given resource.
    def new_resource_comment
      if wall?
        @comment = @wall.comments.new(params[:comment].merge(:person => current_person))
      elsif blog?
        data = { :person => current_person, :post => @post }
        @comment = @post.comments.new(params[:comment].merge(data))
      end      
    end
    
    # Return the template for the current resource given the name.
    # For example, on a blog resource_template("new") gives "blog_new"
    def resource_template(name)
      "#{resource}_#{name}"
    end

    # Return a string for the resource.
    def resource
      if wall?
        "wall"
      elsif blog?
        "post"
      end
    end
    
    # Return the URL for the resource comments.
    def comments_url
      if wall?
        wall_topic_comments_url(@wall, @wall)
      elsif blog?
        blog_post_url(@blog, @post)
      end
    end

    # True if resource lives on a wall.
    def wall?
      !params[:wall_id].nil?
    end

    # True if resource lives in a blog.
    def blog?
      !params[:blog_id].nil?
    end
end
