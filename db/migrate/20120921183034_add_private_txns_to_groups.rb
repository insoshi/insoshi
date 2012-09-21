class AddPrivateTxnsToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :private_txns, :boolean, :default => false
  end
end
