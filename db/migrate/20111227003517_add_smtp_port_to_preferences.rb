class AddSmtpPortToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :smtp_port, :integer
  end

  def self.down
    remove_column :preferences, :smtp_port
  end
end
