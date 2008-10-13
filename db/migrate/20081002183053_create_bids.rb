class CreateBids < ActiveRecord::Migration
  def self.up
    create_table :bids do |t|
      t.integer :req_id
      t.integer :person_id
      t.integer :status_id
      t.decimal :estimated_hours, :precision => 8, :scale => 2, :default => 0
      t.decimal :actual_hours, :precision => 8, :scale => 2, :default => 0
      t.datetime :expiration_date

      t.timestamps
    end
  end

  def self.down
    drop_table :bids
  end
end
