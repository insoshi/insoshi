class AddWaveAllFeesToExchangeAndFees < ActiveRecord::Migration
  def change
    add_column :exchanges, :wave_all_fees, :boolean, default: false
  end
end
