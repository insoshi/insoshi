class AddAboutToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :about, :text
  end

  def self.down
    remove_column :preferences, :about
  end
end
