class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.integer :person_id
      t.integer :blog_comments_count, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :blogs
  end
end
