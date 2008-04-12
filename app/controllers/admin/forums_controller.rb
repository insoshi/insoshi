class Admin::ForumsController < ApplicationController

  before_filter :login_required, :admin_required

  def index
    @forums = Forum.find(:all)

    respond_to do |format|
      format.html
    end
  end

  def show
    raise "fix me"
    redirect_to admin_forum_topics_url(params[:id])
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
        format.html { redirect_to(admin_forums_url) }
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
        format.html { redirect_to(@forum) }
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
      format.html { redirect_to(admin_forums_url) }
    end
  end
end
