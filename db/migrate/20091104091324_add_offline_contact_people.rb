class AddOfflineContactPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :offline_contact, :string
  end

  def self.down
    remove_column :people, :offline_contact
  end
end
