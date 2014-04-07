class AddRequiresCreditCardToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :requires_credit_card, :boolean, :default => true
  end
  
  def self.down
    remove_column :people, :requires_credit_card
  end
end
