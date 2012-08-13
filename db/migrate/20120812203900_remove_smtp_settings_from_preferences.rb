class RemoveSmtpSettingsFromPreferences < ActiveRecord::Migration
  def up
    remove_column :preferences, :domain
    remove_column :preferences, :smtp_server
    remove_column :preferences, :smtp_port
  end

  def down
    add_column :preferences, :smtp_port, :integer
    add_column :preferences, :smtp_server, :string, :null => false, :default => ""
    add_column :preferences, :domain, :string, :null => false, :default => ""
  end
end
