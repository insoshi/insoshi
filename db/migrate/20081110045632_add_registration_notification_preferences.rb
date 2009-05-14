class AddRegistrationNotificationPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :registration_notification, :boolean, :default => false
  end

  def self.down
    remove_column :preferences, :registration_notification
  end
end
