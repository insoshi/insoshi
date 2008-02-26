class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :person_id
      t.integer :blog_id
      t.text :body
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
