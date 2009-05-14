class AddTwitterCredsPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :twitter_name, :string
    add_column :preferences, :crypted_twitter_password, :string
  end

  def self.down
    remove_column :preferences, :twitter_name
    remove_column :preferences, :crypted_twitter_password
  end
end
