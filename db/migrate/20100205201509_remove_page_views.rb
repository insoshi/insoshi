class RemovePageViews < ActiveRecord::Migration
  def self.up
    drop_table :page_views
  end

  def self.down
    create_table "page_views", :force => true do |t|
      t.string   "request_url", :limit => 200
      t.string   "ip_address",  :limit => 16
      t.string   "referer",     :limit => 200
      t.string   "user_agent",  :limit => 200
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "person_id"
    end
    add_index "page_views", ["person_id", "created_at"], :name => "index_page_views_on_person_id_and_created_at"
  end

end
