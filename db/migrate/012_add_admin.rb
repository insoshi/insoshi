class AddAdmin < ActiveRecord::Migration
  def self.up
    add_column :people, :admin, :boolean, :default => false, :null => false
    add_column :people, :deactivated, :boolean, 
                        :default => false, :null => false
    person = Person.new(:email => "admin@#{EMAIL_DOMAIN}",
                        :name => "admin",
                        :password => "admin",
                        :password_confirmation => "admin")
    person.admin = true
    person.save!
  end

  def self.down
    remove_column :people, :deactivated
    Person.find_by_name("admin").destroy
    remove_column :people, :admin
  end
end
