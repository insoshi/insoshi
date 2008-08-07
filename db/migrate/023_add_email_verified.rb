class AddEmailVerified < ActiveRecord::Migration
  
  class Person < ActiveRecord::Base    
  end
  
  def self.up
    add_column :people, :email_verified, :boolean, :default => nil
    if Preference.find(:first).email_verifications?
      # This is to modify the database for the splitting between
      # 'deactivated' and 'email_verified'.
      Person.find(:all).each do |person|
        person.email_verified = !person.deactivated?
        person.save
      end
    end rescue nil
  end

  def self.down
    remove_column :people, :email_verified
  end
end
