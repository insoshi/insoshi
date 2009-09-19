class CreateOffers < ActiveRecord::Migration
  def self.up
    create_table :offers do |t|
      t.string :name
      t.text :description
      t.decimal :price, :precision => 8, :scale => 2, :default => 0
      t.datetime :expiration_date
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :offers
  end
end
