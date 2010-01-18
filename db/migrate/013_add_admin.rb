class AddAdmin < ActiveRecord::Migration
  include Crypto

  class Person < ActiveRecord::Base  
  end
  
  class Blog < ActiveRecord::Base
  end

  def self.up
    add_column :people, :admin, :boolean, :default => false, :null => false
    add_column :people, :deactivated, :boolean, 
                        :default => false, :null => false
   
    local_encryption_key = LocalEncryptionKey.find(:first)
    public_key = Crypto::Key.from_local_key_value(local_encryption_key.rsa_public_key)
    person = Person.new(:email => "admin@example.com",
                        :name => "admin",
                        :crypted_password => public_key.encrypt("admin"),
                        :description => "")
    person.admin = true
    person.save!
    Blog.create(:person_id => person.id)
  end

  def self.down
    remove_column :people, :deactivated
    Person.delete(Person.find_by_name("admin"))
    remove_column :people, :admin
  end
end
