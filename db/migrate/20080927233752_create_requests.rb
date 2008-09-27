class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.string :name
      t.text :description
      t.decimal :estimated_hours
      t.datetime :due_date
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :requests
  end
end
