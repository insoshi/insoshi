class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
      t.text :description
      t.integer :mode, :null => false, :default => 0
      t.integer :person_id

      t.timestamps
    end
    
    create_table :groups_people, :id => false do |t|
      t.integer :group_id
      t.integer :person_id
      
      t.timestamps
    end
    
    add_column :photos, :group_id, :integer
  end

  def self.down
    drop_table :groups
    drop_table :groups_people
    remove_column :photos, :group_id
  end
end
