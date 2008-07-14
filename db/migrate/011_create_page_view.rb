class CreatePageView < ActiveRecord::Migration
  def self.up
    create_table :page_views do |t|
      t.integer :person_id
      t.string :request_url, :limit => 200
      t.string :ip_address, :limit => 16
      t.string :referer, :limit => 200
      t.string :user_agent, :limit => 200

      t.timestamps
    end
    add_index     :page_views, [:person_id, :created_at]
  end

  def self.down
    drop_table :page_views
  end
end