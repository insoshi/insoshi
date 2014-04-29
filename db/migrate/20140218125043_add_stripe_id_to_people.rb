class AddStripeIdToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :stripe_id, :string
  end
  
  def self.down
    remove_column :people, :stripe_id
  end
end
