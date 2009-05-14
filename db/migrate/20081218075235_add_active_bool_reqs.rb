class AddActiveBoolReqs < ActiveRecord::Migration
  def self.up
    add_column :reqs, :active, :boolean, :default => true
  end

  def self.down
    remove_column :reqs, :active
  end
end
