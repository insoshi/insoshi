class AddWallToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :user_walls_enabled, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :preferences, :user_walls_enabled
  end
end
