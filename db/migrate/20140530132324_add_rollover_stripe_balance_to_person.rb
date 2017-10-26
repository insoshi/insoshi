class AddRolloverStripeBalanceToPerson < ActiveRecord::Migration
  def change
    add_column :people, :rollover_balance, :decimal, default: 0
  end
end
