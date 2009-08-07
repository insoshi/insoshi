class CreateFeedPosts < ActiveRecord::Migration
  def self.up
    create_table :feed_posts do |t|
      t.string :feedid
      t.string :title
      t.string :urls
      t.string :categories
      t.text :content
      t.string :authors
      t.datetime :date_published
      t.datetime :last_updated

      t.timestamps
    end
  end

  def self.down
    drop_table :feed_posts
  end
end
