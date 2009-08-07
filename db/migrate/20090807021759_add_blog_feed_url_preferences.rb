class AddBlogFeedUrlPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :blog_feed_url, :string
  end

  def self.down
    remove_column :preferences, :blog_feed_url
  end
end
