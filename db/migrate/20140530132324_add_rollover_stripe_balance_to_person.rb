class AddRolloverStripeBalanceToPerson < ActiveRecord::Migration
  def change
    add_column :people, :rollover_balance, :number, default: 0
  end
end
