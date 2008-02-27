class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :person_id
      t.integer :commenter_id
      t.integer :blog_post_id
      t.text :body
      t.string :type

      t.timestamps
    end
    add_index :comments, :person_id
    add_index :comments, :commenter_id
    add_index :comments, :type
  end

  def self.down
    drop_table :comments
  end
end
