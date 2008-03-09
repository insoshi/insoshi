class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :person_id
      t.integer :instance_id
      t.string :type

      t.timestamps
    end
    add_index :events, :person_id
    add_index :events, :instance_id
    add_index :events, :type
  end

  def self.down
    remove_index :events, :person_id
    add_index :events, :instance_id
    add_index :events, :type
    drop_table :events
  end
end
