class AddTwitterBoolReqs < ActiveRecord::Migration
  def self.up
    add_column :reqs, :twitter, :boolean, :default => false
  end

  def self.down
    remove_column :reqs, :twitter
  end
end
