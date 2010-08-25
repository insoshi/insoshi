class RemoveTwitterPreferences < ActiveRecord::Migration
  def self.up
    remove_column :preferences, :twitter_oauth_consumer_key
    remove_column :preferences, :crypted_twitter_oauth_consumer_secret
    remove_column :preferences, :twitter_api
    remove_column :preferences, :twitter_name
    remove_column :preferences, :crypted_twitter_password
    remove_column :people, :twitter_name
    remove_column :reqs, :twitter
  end

  def self.down
  end
end
