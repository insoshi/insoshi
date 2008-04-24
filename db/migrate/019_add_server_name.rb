class AddServerName < ActiveRecord::Migration
  def self.up
    add_column :preferences, :server_name, :string
  end

  def self.down
    remove_column :preferences, :server_name
  end
end
