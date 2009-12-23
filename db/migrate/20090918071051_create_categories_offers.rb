class CreateCategoriesOffers < ActiveRecord::Migration
  def self.up
    create_table :categories_offers, :id => false do |t|
      t.column :category_id, :integer, :null => false
      t.column :offer_id, :integer, :null => false
    end

    add_index :categories_offers, [:offer_id, :category_id]
    add_index :categories_offers, :category_id
  end

  def self.down
    remove_index :categories_offers, [:offer_id, :category_id]
    remove_index :categories_offers, :category_id
    drop_table :categories_offers
  end
end
