class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :blog_id
      t.integer :topic_id
      t.integer :person_id
      t.string  :title
      t.text    :body
      t.integer :blog_post_comments_count, :null => false, :default => 0
      t.string  :type

      t.timestamps
    end
    add_index :posts, :blog_id
    add_index :posts, :topic_id
    add_index :posts, :type
  end

  def self.down
    drop_table :posts
  end
end
