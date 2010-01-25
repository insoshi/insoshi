class AddAuditsTable < ActiveRecord::Migration
  def self.up
    create_table :audits, :force => true do |t|
      t.column :auditable_id, :integer
      t.column :auditable_type, :string
      t.column :user_id, :integer
      t.column :user_type, :string
      t.column :username, :string
      t.column :action, :string
      t.column :changes, :text
      t.column :version, :integer, :default => 0
      t.column :created_at, :datetime
    end
    
    add_index :audits, [:auditable_id, :auditable_type], :name => 'auditable_index'
    add_index :audits, [:user_id, :user_type], :name => 'user_index'
    add_index :audits, :created_at  

    # This was previously in accounts migration but needs to be after audits for new installs and
    # did not want to create a new migration that would confuse existing installs
    #
    person = Person.find(1)
    account = Account.new( :name => 'personal' )
    account.balance = 0
    account.person = person
    account.save!

    address = Address.new( :name => 'personal' )
    address.person = person
    address.save!
  end

  def self.down
    drop_table :audits
  end
end
