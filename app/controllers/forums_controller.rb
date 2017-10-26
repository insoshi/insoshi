class ForumsController < ApplicationController
  load_resource :group, :only => [:show]
  
  before_filter :login_required, :setup, :credit_card_required

  def show
    @forum = @group.forum
    @authorized = @group.authorized_to_view_forum?(current_person)
    if @authorized
      @topics = Topic.find_recently_active(@forum, ajax_posts_per_page, params[:page])
    else
      flash[:notice] = t('notice_member_to_view_forum')
      @topics = Topic.where('1=0').paginate(:page => 1, :per_page => ajax_posts_per_page)
    end

    respond_to do |format|
      format.js {render :action => 'reject' if not request.xhr?}
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
