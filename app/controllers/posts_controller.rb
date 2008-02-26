class PostsController < ApplicationController
  
  before_filter :login_required
  before_filter :get_instance_vars

  def index
    @posts = model.find(:all)

    respond_to do |format|
      format.html # index.html.erb
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
      # TODO: Switch on forum/blog
      format.html # new.html.erb
    end
  end

  def edit
    @post = model.find(params[:id])
    # TODO: Switch on forum/blog
  end

  def create
    data = { :topic => @topic, :person => current_person }
    @post = model.new(params[:post].merge(data))
    
    respond_to do |format|
      if @post.save
        flash[:success] = 'Post was successfully created.'
        format.html { redirect_to posts_url }
      else
        # TODO: Switch on forum/blog
        format.html { render :action => "new" }
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
