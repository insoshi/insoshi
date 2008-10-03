class CreateBids < ActiveRecord::Migration
  def self.up
    create_table :bids do |t|
      t.integer :req_id
      t.integer :person_id
      t.integer :status_id
      t.decimal :estimated_hours
      t.decimal :actual_hours
      t.datetime :expiration_date

      t.timestamps
    end
  end

  def self.down
    drop_table :bids
  end
end
