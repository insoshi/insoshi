class AddTopicRefreshSecondsToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :topic_refresh_seconds, :integer, {:default => Topic::DEFAULT_REFRESH_SECONDS, :null => false}
  end

  def self.down
    remove_column :preferences, :topic_refresh_seconds
  end
end
