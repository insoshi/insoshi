class RenameEventsToActivities < ActiveRecord::Migration
  def self.up
    remove_index :events, :item_id
    remove_index :events, :item_type
    remove_index :feeds, [:person_id, :event_id]   
    
    rename_table :events, :activities
    rename_column :feeds, :event_id, :activity_id
    
    add_index :activities, :item_id
    add_index :activities, :item_type
    add_index :feeds, [:person_id, :activity_id]   
  end

  def self.down
    remove_index :activities, :item_id
    remove_index :activities, :item_type
    remove_index :feeds, [:person_id, :activity_id] 
    
    rename_table :activities, :events
    rename_column :feeds, :activity_id, :event_id
    
    add_index :events, :item_id
    add_index :events, :item_type
    add_index :feeds, [:person_id, :event_id]   
  end
end
