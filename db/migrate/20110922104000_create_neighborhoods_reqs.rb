class CreateNeighborhoodsReqs < ActiveRecord::Migration
  def self.up
    create_table :neighborhoods_reqs, :id => false do |t|
      t.column :neighborhood_id, :integer, :null => false
      t.column :req_id, :integer, :null => false
    end

    add_index :neighborhoods_reqs, [:req_id, :neighborhood_id]
    add_index :neighborhoods_reqs, :neighborhood_id
  end

  def self.down
    remove_index :neighborhoods_reqs, [:req_id, :neighborhood_id]
    remove_index :neighborhoods_reqs, :neighborhood_id
    drop_table :neighborhoods_reqs
  end
end
