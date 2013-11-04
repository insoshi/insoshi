class AddReserveToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :reserve, :boolean, :default => false
  end
end
