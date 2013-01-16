class AddLogoutUrlToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :logout_url, :string, :default => ""
  end
end
