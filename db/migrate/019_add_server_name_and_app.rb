class AddServerNameAndApp < ActiveRecord::Migration
  def self.up
    add_column :preferences, :server_name, :string
    add_column :preferences, :app_name, :string
  end

  def self.down
    remove_column :preferences, :app_name
    remove_column :preferences, :server_name
  end
end
