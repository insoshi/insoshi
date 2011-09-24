class CreateNeighborhoodsOffers < ActiveRecord::Migration
  def self.up
    create_table :neighborhoods_offers, :id => false do |t|
      t.column :neighborhood_id, :integer, :null => false
      t.column :offer_id, :integer, :null => false
    end

    add_index :neighborhoods_offers, [:offer_id, :neighborhood_id]
    add_index :neighborhoods_offers, :neighborhood_id
  end

  def self.down
    remove_index :neighborhoods_offers, [:offer_id, :neighborhood_id]
    remove_index :neighborhoods_offers, :neighborhood_id
    drop_table :neighborhoods_offers
  end
end
