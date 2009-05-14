class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :name
      t.decimal :balance, :precision => 8, :scale => 2, :default => 0
      t.integer :person_id

      t.timestamps
    end

    person = Person.find(1)
    account = Account.new( :name => 'personal' )
    account.balance = 0
    account.person = person
    account.save!
  end

  def self.down
    drop_table :accounts
  end
end
