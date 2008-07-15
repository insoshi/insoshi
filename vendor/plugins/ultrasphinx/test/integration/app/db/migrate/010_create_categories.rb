class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table "categories" do |t|
      t.string  "name",           :default => "", :null => false
      t.integer "parent_id"
      t.integer "children_count"
      t.string  "permalink"
    end
  end

  def self.down
    drop_table :categories
  end
end
