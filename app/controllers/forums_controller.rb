class ForumsController < ApplicationController
  load_resource :group, :only => [:show]
  
  before_filter :login_required, :setup

  def show
    @forum = @group.forum
    if @group.authorized_to_view_forum?(current_person)
      @topics = Topic.find_recently_active(@forum, params[:page]) 
    else
      @topics = Topic.where('1=0').paginate(:page => 1, :per_page => AJAX_POSTS_PER_PAGE)
    end

    respond_to do |format|
      format.js
    end
  end

  def update
    @forum = Forum.find(params[:id])
    respond_to do |format|
      if @forum.update_attributes(params[:forum])
        flash[:notice] = t('notice_forum_updated')
        format.js
      else
        flash[:error] = t('error_invalid_action')
        format.js
      end
    end
  end

  private
  
    def setup
      @body = "forum"
    end
end
