class AddPrivacyToAddress < ActiveRecord::Migration
  def self.up
    add_column :addresses, :address_privacy, :boolean, :default => false
  end

  def self.down
    remove_column :addresses, :address_privacy
  end
end
