class CategoriesSellers < ActiveRecord::Migration
  def self.up
    create_table "categories_sellers", :id => false, :force => true do |t|
      t.integer "category_id", :null => false
      t.integer "seller_id",   :null => false
    end

    add_index "categories_sellers", ["category_id"], :name => "index_categories_sellers_on_category_id"
    add_index "categories_sellers", ["seller_id"], :name => "index_categories_sellers_on_seller_id"
  end

  def self.down
    drop_table "categories_sellers"
  end
end
