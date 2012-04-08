class AddBroadcastEmailsToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :broadcast_emails, :boolean
  end

  def self.down
    remove_column :people, :broadcast_emails
  end
end
