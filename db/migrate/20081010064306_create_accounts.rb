class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :name
      t.decimal :balance, :precision => 8, :scale => 2, :default => 0
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
