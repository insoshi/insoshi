class AddWorldwritableToForums < ActiveRecord::Migration
  def self.up
    add_column :forums, :worldwritable, :boolean, :default => false
  end

  def self.down
    remove_column :forums, :worldwritable
  end
end
