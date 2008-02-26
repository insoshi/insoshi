class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.integer :forum_id
      t.integer :person_id
      t.string  :name
      t.integer :forum_posts_count, :null => false, :default => 0

      t.timestamps
    end
    add_index :topics, :forum_id
  end

  def self.down
    drop_table :topics
  end
end
