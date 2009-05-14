class AddStateBids < ActiveRecord::Migration
  def self.up
    add_column :bids, :state, :string
  end

  def self.down
    remove_column :bids, :state
  end
end
