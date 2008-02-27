class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table "people", :force => true do |t|
      t.string   :email, :name, :remember_token, :crypted_password
      t.text     :description
      t.datetime :remember_token_expires_at,
                 :last_contacted_at,
                 :last_logged_in_at
      t.integer  :forum_posts_count, :null => false, :default => 0
      t.integer  :blog_post_comments_count, :null => false, :default => 0
      t.integer  :wall_comments_count, :null => false, :default => 0
      t.timestamps
    end
    add_index :people, :email
    add_index :people, :remember_token
  end

  def self.down
    drop_table "people"
  end
end
