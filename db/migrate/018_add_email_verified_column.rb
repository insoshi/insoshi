class AddEmailVerifiedColumn < ActiveRecord::Migration
  def self.up
    add_column :people, :email_verified, :boolean, :default => true
  end

  def self.down
    remove_column :people, :email_verified
  end
end
