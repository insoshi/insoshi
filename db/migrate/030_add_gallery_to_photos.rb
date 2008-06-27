require 'app/helpers/photos_helper'

class AddGalleryToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :gallery_id, :integer
    add_column :photos, :title, :string
    Photos.find(:all).each do |ph|
      ph.gallery_id = ph.person.galleries.find(:first).id
      ph.title = photo_title(ph.filename)
      photo.save!
    end
    remove_column :photos, :primary
  end

  def self.down
    # build a hash of the primary photo id of all the existing galleries
    gals = {}
    Gallery.find(:all).each do |gall|
      gals[gall.id] = gall.primary_photo_id
    end
    remove_column :photos, :gallery_id
    remove_column :photos, :title
    add_column :photos, :primary
    Photo.find(:all).each do |photo|
        photo.primary = gals.has_value?(photo.id)
        photo.save!
    end
  end
end
