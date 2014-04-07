class CreateFees < ActiveRecord::Migration
  def change
    create_table :fees do |t|
      t.references :fee_plan
      t.string :type
      t.integer :recipient_id
      t.decimal :percent, :precision => 8, :scale => 7, :default => 0.0
      t.decimal :amount, :precision => 8, :scale => 2, :default => 0.0
      t.string :interval

      t.timestamps
    end
    add_index :fees, :fee_plan_id
  end
end
