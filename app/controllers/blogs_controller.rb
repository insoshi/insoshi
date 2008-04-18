class BlogsController < ApplicationController

  def show
    @blog = Blog.find(params[:id])
    @posts = @blog.posts.paginate(:page => params[:page])
    
    respond_to do |format|
      format.html
    end
  end
end
