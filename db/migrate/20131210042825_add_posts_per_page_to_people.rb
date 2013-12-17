class AddPostsPerPageToPeople < ActiveRecord::Migration
  def change
    add_column :people, :posts_per_page, :integer, :default => 25
  end
end
