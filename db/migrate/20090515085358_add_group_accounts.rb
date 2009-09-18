class AddGroupAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :group_id, :integer
  end

  def self.down
    remove_column :accounts, :group_id
  end
end
