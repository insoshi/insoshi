class AddAdmin < ActiveRecord::Migration
  def self.up
    person = Person.new(:email => "admin@example.com",
                        :name => "admin",
                        :password => "admin",
                        :password_confirmation => "admin")
    person.admin = true
    person.save!
    
    gallery = Gallery.create!(:person => person, :title => 'Primary', :description => 'Default Insoshi Gallery')
  end

  def self.down
  end
end
