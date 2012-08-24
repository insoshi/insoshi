class RemoveBlogsEventsAndWalls < ActiveRecord::Migration
  def up
    drop_table "blogs"
    drop_table "comments"
    drop_table "event_attendees"
    drop_table "events"
    remove_column :people, :blog_post_comments_count
    remove_column :people, :wall_comments_count
    remove_column :people, :wall_comment_notifications
    remove_column :people, :blog_comment_notifications
    remove_column :preferences, :user_walls_enabled
  end

  def down

    add_column :people, :blog_post_comments_count, :integer, :default => 0, :null => false
    add_column :people, :wall_comments_count, :integer, :default => 0, :null => false
    add_column :people, :wall_comment_notifications, :boolean, :default => true
    add_column :people, :blog_comment_notifications, :boolean, :default => true
    remove_column :preferences, :user_walls_enabled, :boolean, :default => false, :null => false

    create_table "blogs", :force => true do |t|
      t.integer  "person_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "blogs", ["person_id"]

    create_table "comments", :force => true do |t|
      t.integer  "commenter_id"
      t.integer  "commentable_id"
      t.string   "commentable_type", :default => "", :null => false
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "comments", ["commentable_id", "commentable_type"]
    add_index "comments", ["commenter_id"]

    create_table "event_attendees", :force => true do |t|
      t.integer "person_id"
      t.integer "event_id"
    end

    create_table "events", :force => true do |t|
      t.string   "title",                                :null => false
      t.string   "description"
      t.integer  "person_id",                            :null => false
      t.datetime "start_time",                           :null => false
      t.datetime "end_time"
      t.boolean  "reminder"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "event_attendees_count", :default => 0
      t.integer  "privacy",               :default => 2, :null => false
    end

  end
end
