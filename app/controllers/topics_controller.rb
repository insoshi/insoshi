class TopicsController < ApplicationController
  load_resource :forum
  load_and_authorize_resource :topic, :through => :forum
  
  before_filter :login_required, :credit_card_required
  
  def index
    redirect_to forum_url(params[:forum_id])
  end

  def show
    @group = @forum.group
    @authorized = @group.authorized_to_view_forum?(current_person)
    if @authorized
      @posts = @topic.posts.paginate(:page => params[:page], :per_page => ajax_posts_per_page)
    else
      @posts = ForumPost.where('1=0').paginate(:page => 1, :per_page => ajax_posts_per_page)
    end
    @post = ForumPost.new
    respond_to do |format|
      format.html
      format.js do
        if request.xhr?
          @refresh_milliseconds = global_prefs.topic_refresh_seconds * 1000
        else
          render :action => 'reject'
        end
      end
    end
  end

  def create
    @body = "yui-skin-sam" 
    @topic.person = current_person
    @post = ForumPost.new

    respond_to do |format|
      if @topic.save
        flash[:notice] = t('success_topic_created')
        format.html { redirect_to forum_topic_path(@forum, @topic) }
        format.js
      else
        format.html { render :action => "new" }
      end
    end
  end

  def destroy
    @topic.destroy

    respond_to do |format|
      flash[:notice] = t('success_topic_destroyed')
      format.js
    end
  end
end
