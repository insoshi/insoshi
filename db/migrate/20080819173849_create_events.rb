class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :title, :null => false
      t.string :description
      t.references :person, :null => false
      t.datetime :start_time, :null => false
      t.datetime :end_time
      t.boolean :reminder

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
