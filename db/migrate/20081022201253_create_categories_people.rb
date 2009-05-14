class CreateCategoriesPeople < ActiveRecord::Migration
  def self.up
    create_table :categories_people, :id => false do |t|
      t.column :category_id, :integer, :null => false
      t.column :person_id, :integer, :null => false
    end

    add_index :categories_people, [:person_id, :category_id]
    add_index :categories_people, :category_id
  end

  def self.down
    remove_index :categories_people, [:person_id, :category_id]
    remove_index :categories_people, :category_id
    drop_table :categories_people
  end
end
