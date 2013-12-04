class AddPublicPrivateBidToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :public_private_bid, :boolean, :default => false
  end
end
