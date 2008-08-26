class CreatePageView < ActiveRecord::Migration
  def self.up
    create_table :page_views do |t|
      t.integer :user_id
      t.string :request_url, :limit => 200
      t.string :session, :limit => 32
      t.string :ip_address, :limit => 16
      t.string :referer, :limit => 200
      t.string :user_agent, :limit => 200

      t.timestamps
    end
  end

  def self.down
    drop_table :page_views
  end
end