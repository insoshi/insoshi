class AddGroupsToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :groups, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :preferences, :groups
  end
end
