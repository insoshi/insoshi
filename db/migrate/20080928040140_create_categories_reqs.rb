class CreateCategoriesReqs < ActiveRecord::Migration
  def self.up
    create_table :categories_reqs, :id => false do |t|
      t.column :category_id, :integer, :null => false
      t.column :req_id, :integer, :null => false
    end

    add_index :categories_reqs, [:req_id, :category_id]
    add_index :categories_reqs, :category_id
  end

  def self.down
    remove_index :categories_reqs, [:req_id, :category_id]
    remove_index :categories_reqs, :category_id
    drop_table :categories_reqs
  end
end
