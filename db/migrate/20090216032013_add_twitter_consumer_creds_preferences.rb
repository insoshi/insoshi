class AddTwitterConsumerCredsPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :twitter_oauth_consumer_key, :string
    add_column :preferences, :crypted_twitter_oauth_consumer_secret, :string
  end

  def self.down
    remove_column :preferences, :twitter_oauth_consumer_key
    remove_column :preferences, :crypted_twitter_oauth_consumer_secret
  end
end
