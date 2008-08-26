class AddAnalyticsPreference < ActiveRecord::Migration
  def self.up
    add_column :preferences, :analytics, :text
  end

  def self.down
    remove_column :preferences, :analytics
  end
end
