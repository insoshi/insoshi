class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
        t.integer :person_id
        t.string :name, :null => true, :limit => 50
        t.string :address_line_1, :null => true, :limit => 50
        t.string :address_line_2, :null => true, :limit => 50
        t.string :address_line_3, :null => true, :limit => 50
        t.string :city, :null => true, :limit => 50
        t.string :county_id, :null => true
        t.integer :state_id, :null => true
        t.string :zipcode_plus_4, :null => true, :limit => 10
        t.decimal :latitude, :precision => 12, :scale => 8
        t.decimal :longitude, :precision => 12, :scale => 8
      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
