class ForumsController < ApplicationController
  load_resource :group, :only => [:show]
  
  before_filter :login_required, :setup

  def show
    @forum = @group.forum
    @topics = Topic.find_recently_active(@forum, params[:page]) 
    respond_to do |format|
      format.js
    end
  end

  def update
    @forum = Forum.find(params[:id])
    respond_to do |format|
      if @forum.update_attributes(params[:forum])
        flash[:notice] = t('notice_forum_updated')
        format.html {redirect_to edit_group_path(@forum.group)}
      else
        format.html { render :action => "edit" }
      end
    end
  end

  private
  
    def setup
      @body = "forum"
    end
end
