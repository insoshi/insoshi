class AddTwitterApiPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :twitter_api, :string
  end

  def self.down
    remove_column :preferences, :twitter_api
  end
end
