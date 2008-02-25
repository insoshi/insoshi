class PostsController < ApplicationController
  
  before_filter :get_forum_and_topic

  def index
    @posts = Post.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def create
    @post = Post.new(params[:post])

    respond_to do |format|
      if @post.save
        flash[:success] = 'Post was successfully created.'
        format.html { redirect_to forum_topic_posts_url(@forum, @topic) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:success] = 'Post was successfully updated.'
        format.html { redirect_to forum_topic_posts_url(@forum, @topic) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to forum_topic_posts_url(@forum, @topic) }
    end
  end
  
  private
  
    def get_forum_and_topic
      @forum = Forum.find(params[:forum_id])
      @topic = Topic.find(params[:topic_id])
    end
end
