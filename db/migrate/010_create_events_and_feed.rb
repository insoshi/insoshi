class CreateEventsAndFeed < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.boolean :public
      t.integer :item_id
      t.integer :person_id
      t.string :item_type

      t.timestamps
    end
    add_index :events, :item_id
    add_index :events, :item_type
    
    create_table :feeds do |t|
      t.integer :person_id
      t.integer :event_id
    end
    
    add_index :feeds, [:person_id, :event_id]    
  end

  def self.down
    drop_table :events
    drop_table :feeds
  end
end
