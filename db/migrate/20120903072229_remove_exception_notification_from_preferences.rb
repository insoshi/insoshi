class RemoveExceptionNotificationFromPreferences < ActiveRecord::Migration
  def up
    remove_column :preferences, :exception_notification
  end

  def down
    add_column :preferences, :exception_notification, :string
  end
end
