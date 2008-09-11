class AddWhitelistBoolPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :whitelist, :boolean, :default => false
  end

  def self.down
    remove_column :preferences, :whitelist
  end
end
