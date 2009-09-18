class AddAdhocCurrencyBoolGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :adhoc_currency, :boolean, :default => false
  end

  def self.down
    remove_column :groups, :adhoc_currency
  end
end
