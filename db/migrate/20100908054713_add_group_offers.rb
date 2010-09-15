class AddGroupOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :group_id, :integer
  end

  def self.down
    remove_column :offers, :group_id
  end
end
