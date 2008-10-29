class AddExceptionNotificationPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :exception_notification, :string
  end

  def self.down
    remove_column :preferences, :exception_notification, :string
  end
end
