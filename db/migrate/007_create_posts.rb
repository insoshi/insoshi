class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :blog_id
      t.integer :topic_id
      t.integer :person_id
      t.text    :body
      t.string  :type

      t.timestamps
    end
    add_index :posts, :blog_id
    add_index :posts, :topic_id
  end

  def self.down
    drop_table :posts
  end
end
