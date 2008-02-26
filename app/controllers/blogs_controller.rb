class BlogsController < ApplicationController

  def show
    @blog = Blog.find(params[:id])
    @posts = @blog.posts
    
    respond_to do |format|
      format.html
    end
  end

end
