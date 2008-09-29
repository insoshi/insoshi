# NOTE: We use "comments" for both wall topic comments and blog comments,
# There is some trickery to handle the two in a unified manner.
class CommentsController < ApplicationController
  
  before_filter :login_required
  before_filter :get_instance_vars
  before_filter :authorize_destroy, :only => [:destroy]
  before_filter :connection_required

  def index
    redirect_to comments_url
  end

  def show
    redirect_to comments_url
  end

  # Used for both wall and blog comments.
  def new
    @comment = parent.comments.new

    respond_to do |format|
      format.html { render :action => resource_template("new") }
    end
  end

  # Used for both wall and blog comments.
  def create
    @comment = parent.comments.build(params[:comment])
    @comment.commenter = current_person
    
    respond_to do |format|
      if @comment.save
        flash[:success] = 'Comment was successfully created.'
        format.html { redirect_to comments_url }
      else
        format.html { render :action => resource_template("new") }
      end
    end
  end

  def destroy
    commentable = @comment.commentable
    @comment.destroy

    respond_to do |format|
      flash[:success] = "Comment deleted"
      format.html { redirect_to comments_url }
    end
  end
  
  private
  
    def get_instance_vars
      if wall?
        @person = Person.find(params[:person_id])
      elsif blog?
        @blog = Blog.find(params[:blog_id])
        @post = Post.find(params[:post_id])
      elsif event?
        @event = Event.find(params[:event_id])
      end
    end
  
    def person
      if wall?
        @person
      elsif blog?
        @blog.person 
      elsif event?
        @event.person
      end
    end
    
    # Require the users to be connected.
    def connection_required
      if wall?
        unless connected_to?(person)
          flash[:notice] = "You must be contacts to complete that action"
          redirect_to @person
        end
      end
    end
    
    def authorized_to_destroy?
      @comment = Comment.find(params[:id])
      if wall?
        current_person?(person) or current_person?(@comment.commenter)
      elsif blog?
        current_person?(person)
      end
    end
    
    def authorize_destroy
      redirect_to home_url unless authorized_to_destroy?
    end
    
    ## Handle wall and blog comments in a uniform manner.
    
    # Return the comments array for the given resource.
    def resource_comments
      if wall?
        @person.comments
      elsif blog?
        @post.comments.paginate(:page => params[:page])
      elsif
        @event.comments
      end  
    end
    
    # Return a the parent (person or blog post) of the comment.
    def parent
      if wall?
        @person
      elsif blog?
        @post
      elsif event?
        @event
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
        "blog_post"
      elsif event?
        "event"
      end
    end
    
    # Return the URL for the resource comments.
    def comments_url
      if wall?
        (person_url @person)+'#tWall'  # go directly to comments tab
      elsif blog?
        blog_post_url(@blog, @post)
      elsif event?
        @event
      end
    end

    # True if resource lives on a wall.
    def wall?
      !params[:person_id].nil?
    end

    # True if resource lives in a blog.
    def blog?
      !params[:blog_id].nil?
    end

    def event?
      !params[:event_id].nil?
    end
end
