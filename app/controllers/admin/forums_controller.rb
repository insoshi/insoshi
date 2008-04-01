class Admin::ForumsController < ApplicationController

  before_filter :login_required

  def index
    @forums = Forum.find(:all)

    respond_to do |format|
      format.html
    end
  end

  def show
    redirect_to admin_forum_topics_url(params[:id])
  end

  def new
    @forum = Forum.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @forum }
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
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @forum.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @forum = Forum.find(params[:id])
    @forum.destroy

    respond_to do |format|
      format.html { redirect_to(admin_forums_url) }
      format.xml  { head :ok }
    end
  end
end
