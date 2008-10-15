class MigratePhotoData < ActiveRecord::Migration
  
  def self.up
    # For each person, create a gallery and put all their photos there.
    Person.find(:all) do |person|
      gallery = person.galleries.create
      gallery.title = "Primary gallery"
      gallery.primary_photo_id = person.photo.id
      gallery.save!
      person.photos.each do |photo|
        photo.gallery_id = gallery.id
        photo.avatar = photo.primary
        photo.save!
      end
    end
    remove_column :photos, :primary
  end

  def self.down
    add_column :photos, :primary, :boolean
    Gallery.find(:all).each do |gallery|
      gallery.destroy
    end
    Photo.find(:all).each do |photo|
      photo.gallery_id = nil
      photo.primary = photo.avatar
      photo.save(false)
    end
  end
end
