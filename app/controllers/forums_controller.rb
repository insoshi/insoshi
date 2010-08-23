class ForumsController < ApplicationController
  
  before_filter :login_required, :setup

  def index
    @forum = Forum.first(:conditions => "group_id is NULL")
    redirect_to forum_url(@forum) and return
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
