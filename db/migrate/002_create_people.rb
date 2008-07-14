class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table "people", :force => true do |t|
      t.string   :email, :name, :remember_token, :crypted_password
      t.text     :description
      t.integer  :avatar_id
      t.datetime :remember_token_expires_at,
                 :last_contacted_at,
                 :last_logged_in_at
      t.integer  :forum_posts_count, :null => false, :default => 0
      t.integer  :blog_post_comments_count, :null => false, :default => 0
      t.integer  :wall_comments_count, :null => false, :default => 0
      t.boolean  :admin, :default => false, :null => false
      t.boolean  :deactivated, :default => false, :null => false
      t.boolean  :connection_notifications, :default => true
      t.boolean  :message_notifications, :default => true
      t.boolean  :wall_comment_notifications, :default => true
      t.boolean  :blog_comment_notifications, :default => true
      t.boolean  :email_verified, :default => nil

      t.timestamps
    end
    add_index :people, :email, :unique => true
    add_index :people, :remember_token
    add_index :people, :admin
    add_index :people, :deactivated
  end

  def self.down
    drop_table "people"
  end
end