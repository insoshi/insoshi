class AddDefaultGroupToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :default_group_id, :integer
  end

  def self.down
    remove_column :preferences, :default_group_id
  end
end
