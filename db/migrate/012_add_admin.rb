class AddAdmin < ActiveRecord::Migration
  def self.up
    add_column :people, :admin, :boolean
    add_column :people, :deactivated, :string
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
