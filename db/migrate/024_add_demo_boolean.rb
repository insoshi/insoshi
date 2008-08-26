class AddDemoBoolean < ActiveRecord::Migration
  def self.up
    add_column :preferences, :demo, :boolean, :default => false
  end

  def self.down
    remove_column :preferences, :demo
  end
end
