class AddGroupOptionPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :group_option, :boolean, :default => false
  end

  def self.down
    remove_column :preferences, :group_option
  end
end
