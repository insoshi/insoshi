class AddInvalidatedAtToCapabilities < ActiveRecord::Migration
  def self.up
    add_column :capabilities, :invalidated_at, :timestamp
  end

  def self.down
    remove_column :capabilities, :invalidated_at
  end
end
