class AddPublicBidToReqs < ActiveRecord::Migration
  def change
    add_column :reqs, :public_bid, :boolean, :default => false
  end
end
