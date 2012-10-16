class RemoveZipcodeBrowsingFromPreferences < ActiveRecord::Migration
  def up
    remove_column :preferences, :zipcode_browsing
  end

  def down
    add_column :preferences, :zipcode_browsing, :boolean, :default => false
  end
end
