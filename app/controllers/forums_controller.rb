class ForumsController < ApplicationController

  before_filter :login_required

  def index
    @forums = Forum.find(:all)
    if @forums.length == 1
      redirect_to forum_topics_url(@forums.first) and return
    end

    respond_to do |format|
      format.html
    end
  end

  def show
    redirect_to admin_forum_topics_url(params[:id])
  end
end
