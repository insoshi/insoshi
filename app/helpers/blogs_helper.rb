module BlogsHelper
  def blog_tab_path(blog)
    person_path(blog.person, :anchor => "tBlog")
  end

  def blog_tab_url(blog)
    person_url(blog.person, :anchor => "tBlog")
  end  
end
