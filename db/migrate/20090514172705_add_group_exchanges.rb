class AddGroupExchanges < ActiveRecord::Migration
  def self.up
    add_column :exchanges, :group_id, :integer
  end

  def self.down
    remove_column :exchanges, :group_id
  end
end
