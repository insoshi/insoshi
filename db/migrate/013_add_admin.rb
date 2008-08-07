class AddAdmin < ActiveRecord::Migration

  class Person < ActiveRecord::Base  
  end
  
  class Blog < ActiveRecord::Base
  end

  def self.up
    add_column :people, :admin, :boolean, :default => false, :null => false
    add_column :people, :deactivated, :boolean, 
                        :default => false, :null => false
    
    key = Crypto::Key.from_file("#{RAILS_ROOT}/rsa_key.pub")
    person = Person.new(:email => "admin@example.com",
                        :name => "admin",
                        :crypted_password => key.encrypt("admin"),
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
