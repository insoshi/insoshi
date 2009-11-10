class AddNewMemberNotificationPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :new_member_notification, :string
    remove_column :preferences, :registration_notification
  end

  def self.down
    remove_column :preferences, :new_member_notification
    add_column :preferences, :registration_notification, :boolean
  end
end
