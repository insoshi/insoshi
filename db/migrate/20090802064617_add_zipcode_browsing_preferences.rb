class AddZipcodeBrowsingPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :zipcode_browsing, :boolean, :default => false
  end

  def self.down
    remove_column :preferences, :zipcode_browsing
  end
end
