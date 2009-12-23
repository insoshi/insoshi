class AddTotalAvailableAndAvailableCountToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :total_available, :integer
    add_column :offers, :available_count, :integer
  end

  def self.down
    remove_column :offers, :total_available
    remove_column :offers, :available_count
  end
end
