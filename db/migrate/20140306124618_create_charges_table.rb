class CreateChargesTable < ActiveRecord::Migration
  def self.up
    create_table :charges do |t|
      t.string  :stripe_id
      t.string  :description
      t.float   :amount
      t.string :status
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :charges
  end
end
