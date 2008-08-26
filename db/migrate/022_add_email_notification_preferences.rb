class AddEmailNotificationPreferences < ActiveRecord::Migration
  def self.up
    add_column :people, :connection_notifications, :boolean, :default => true
    add_column :people, :message_notifications, :boolean, :default => true
    add_column :people, :wall_comment_notifications, :boolean, :default => true
    add_column :people, :blog_comment_notifications, :boolean, :default => true
  end

  def self.down
    remove_column :people, :blog_comment_notifications
    remove_column :people, :wall_comment_notifications
    remove_column :people, :message_notifications
    remove_column :people, :connection_notifications
  end
end
