class ForumsController < ApplicationController
  load_resource :group
  
  before_filter :login_required, :setup

  def show
    @forum = @group.forum
    @topics = Topic.find_recently_active(@forum, params[:page]) 
    respond_to do |format|
      format.js
    end
  end
  
  private
  
    def setup
      @body = "forum"
    end
end
