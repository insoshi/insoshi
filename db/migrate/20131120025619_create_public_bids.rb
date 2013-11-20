class CreatePublicBids < ActiveRecord::Migration
  def change
    create_table :public_bids do |t|
      t.boolean :public_bid

      t.timestamps
    end

    PublicBid.create!(:public_bid => true)
  end
end
