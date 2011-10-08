class AddActivatorToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :activator, :boolean, :default => false
  end

  def self.down
    remove_column :people, :activator
  end
end
