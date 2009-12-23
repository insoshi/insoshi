class AddPhoneprivacyBoolPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :phoneprivacy, :boolean, :default => false
  end

  def self.down
    remove_column :people, :phoneprivacy
  end
end
