class CreateStripeFees < ActiveRecord::Migration
  def change
    create_table :stripe_fees do |t|
      t.references :fee_plan
      t.string :type
      t.decimal :percent, :precision => 8, :scale => 7, :default => 0.0
      t.decimal :amount, :precision => 8, :scale => 2, :default => 0.0
      t.string :interval
      t.string :plan

      t.timestamps
    end
    add_index :stripe_fees, :fee_plan_id
  end
end
