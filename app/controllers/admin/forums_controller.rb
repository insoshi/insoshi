class Admin::ForumsController < ApplicationController

  before_filter :login_required, :admin_required, :setup
  before_filter :protect_last_forum, :only => :destroy
  

  def index
    @forums = Forum.find(:all)
    respond_to do |format|
      format.html
    end
  end

  def show
    @forum = Forum.find(params[:id])
    @topics = @forum.topics.paginate(:page => params[:page])
    respond_to do |format|
      format.html { render :template => "forums/show"}
    end
  end

  def new
    @forum = Forum.new

    respond_to do |format|
      format.html
    end
  end

  def edit
    @forum = Forum.find(params[:id])
  end

  def create
    @forum = Forum.new(params[:forum])

    respond_to do |format|
      if @forum.save
        flash[:notice] = 'Forum was successfully created.'
        format.html { redirect_to admin_forums_url }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @forum = Forum.find(params[:id])

    respond_to do |format|
      if @forum.update_attributes(params[:forum])
        flash[:notice] = 'Forum was successfully updated.'
        format.html { redirect_to admin_forums_path  }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @forum = Forum.find(params[:id])
    @forum.destroy

    respond_to do |format|
      flash[:success] = 'Forum was successfully destroyed.'
      format.html { redirect_to admin_forums_url }
    end
  end

  private

    def setup
      @body = "forum"
    end
    
    def protect_last_forum
      if Forum.count == 1
        flash[:error] = "There must be at least one forum."
        redirect_to admin_forums_url
      end
    end
end
