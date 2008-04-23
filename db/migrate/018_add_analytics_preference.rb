class AddAnalyticsPreference < ActiveRecord::Migration
  def self.up
    add_column :preferences, :analytics, :text
    Preference.create! if Preference.count.zero?
  end

  def self.down
    remove_column :preferences, :analytics
  end
end
