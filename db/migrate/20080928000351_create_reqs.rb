class CreateReqs < ActiveRecord::Migration
  def self.up
    create_table :reqs do |t|
      t.string :name
      t.text :description
      t.decimal :estimated_hours, :precision => 8, :scale => 2, :default => 0
      t.datetime :due_date
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :reqs
  end
end
