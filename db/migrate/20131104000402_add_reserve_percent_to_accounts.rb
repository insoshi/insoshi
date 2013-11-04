class AddReservePercentToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :reserve_percent, :decimal, :precision => 8, :scale => 7, :default => 0
  end
end
