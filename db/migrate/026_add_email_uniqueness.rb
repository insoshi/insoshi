class AddEmailUniqueness < ActiveRecord::Migration
  def self.up
    remove_index :people, :email
    add_index :people, :email, :unique => true
  end

  def self.down
    remove_index :people, :email
    add_index :people, :email
  end
end
