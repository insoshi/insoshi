class CreateNeighborhoodsPeople < ActiveRecord::Migration
  def self.up
    create_table :neighborhoods_people, :id => false do |t|
      t.column :neighborhood_id, :integer, :null => false
      t.column :person_id, :integer, :null => false
    end

    add_index :neighborhoods_people, [:person_id, :neighborhood_id]
    add_index :neighborhoods_people, :neighborhood_id
  end

  def self.down
    remove_index :neighborhoods_people, [:person_id, :neighborhood_id]
    remove_index :neighborhoods_people, :neighborhood_id
    drop_table :neighborhoods_people
  end
end
