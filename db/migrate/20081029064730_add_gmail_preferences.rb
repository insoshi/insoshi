class AddGmailPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :gmail, :string
  end

  def self.down
    remove_column :preferences, :gmail
  end
end
