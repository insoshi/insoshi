class RemoveSmtpSettingsFromPreferences < ActiveRecord::Migration
  def up
    remove_column :preferences, :domain
    remove_column :preferences, :smtp_server
    remove_column :preferences, :smtp_port
  end

  def down
  end
end
