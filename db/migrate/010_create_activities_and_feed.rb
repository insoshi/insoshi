class CreateActivitiesAndFeed < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.boolean :public
      t.integer :item_id
      t.integer :person_id
      t.string :item_type

      t.timestamps
    end
    add_index :activities, :item_id
    add_index :activities, :item_type
    
    create_table :feeds do |t|
      t.integer :person_id
      t.integer :activity_id
    end
    
    add_index :feeds, [:person_id, :activity_id]    
  end

  def self.down
    drop_table :activities
    drop_table :feeds
  end
end
