class AddOffsetToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :offset, :decimal, :precision => 8, :scale => 2, :default => 0
  end
end
