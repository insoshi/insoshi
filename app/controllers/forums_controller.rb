class ForumsController < ApplicationController
  
  before_filter :login_required, :setup

  def index
    @forums = Forum.find(:all)
    if @forums.length >= 1
      redirect_to forum_url(@forums.first) and return
    end

    respond_to do |format|
      format.html
    end
  end

  def show
    @forum = Forum.find(params[:id])
    #@topics = @forum.topics.paginate(:page => params[:page])
    @topics = Topic.find_recently_active(@forum, params[:page]) 
  end
  
  private
  
    def setup
      @body = "forum"
    end
end
