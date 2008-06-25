class MoveUserPrefsToHasEasy < ActiveRecord::Migration
  def self.up
    Person.find(:all).each do |p|
      p.prefs.en_connections = p.connection_notifications
      p.prefs.en_messages = p.message_notifications
      p.prefs.en_walls = p.wall_comment_notifications
      p.prefs.en_blogs = p.blog_comment_notifications
      p.save!
    end
    remove_column :people, :connection_notifications
    remove_column :people, :message_notifications
    remove_column :people, :wall_comment_notifications
    remove_column :people, :blog_comment_notifications
  end

  def self.down
    add_column :people, :connection_notifications, :default => false
    add_column :people, :message_notifications, :default => false
    add_column :people, :wall_comment_notifications, :default => false
    add_column :people, :blog_comment_notifications, :default => false
    Person.find(:all).each do |p|
      p.connection_notifications = p.prefs.en_connections
      p.message_notifications = p.prefs.en_messages
      p.wall_comment_notifications = p.prefs.en_walls
      p.blog_comment_notifications = p.prefs.en_blogs
      p.save!
    end
  end
end
