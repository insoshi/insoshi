class AddOpenidToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :openid, :boolean, :default => true
  end
end
