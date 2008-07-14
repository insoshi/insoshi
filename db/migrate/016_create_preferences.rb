class CreatePreferences < ActiveRecord::Migration
  def self.up
    # drop_table :preferences rescue nil
    create_table :preferences do |t|
      t.string  :domain, :null => false, :default => ""
      t.string  :smtp_server, :null => false, :default => ""
      t.boolean :email_notifications, :null => false, :default => false
      t.boolean :email_verifications, :null => false, :default => false
      t.text    :analytics
      t.string  :server_name
      t.string  :app_name
      t.text    :about
      t.boolean :demo, :default => false
      t.string  :sidebar_title
      t.text    :sidebar_body
      
      t.timestamps
    end
  end

  def self.down
    drop_table :preferences
  end
end
