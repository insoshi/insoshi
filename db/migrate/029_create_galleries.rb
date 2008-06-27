class CreateGalleries < ActiveRecord::Migration
  def self.up
    create_table :galleries do |t|
      t.integer :person_id
      t.string :title
      t.string :description
      t.integer :photos_count, :null => false, :default => 0
      t.integer :primary_photo_id
      t.timestamps
    end
    Person.find(:all).each do |person|
      prime = person.photos.find(:first, :conditions => 'primary = true')
      gall = Gallery.new(:person => person)
      gall.title = 'Primary'
      gall.description = 'Default ' + app_name + ' Gallery'
      gall.primary_photo_id = prime.id
      gall.save!
    end
  end

  def self.down
    drop_table :galleries
  end
end
