class AddTimestampsBids < ActiveRecord::Migration
  def self.up
    add_column :bids, :accepted_at, :datetime
    add_column :bids, :committed_at, :datetime
    add_column :bids, :completed_at, :datetime
    add_column :bids, :approved_at, :datetime
    add_column :bids, :rejected_at, :datetime
  end

  def self.down
    remove_column :bids, :rejected_at
    remove_column :bids, :approved_at
    remove_column :bids, :completed_at
    remove_column :bids, :committed_at
    remove_column :bids, :accepted_at
  end
end
