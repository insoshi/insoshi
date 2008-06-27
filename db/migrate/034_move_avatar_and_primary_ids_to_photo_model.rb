class MoveAvatarAndPrimaryIdsToPhotoModel < ActiveRecord::Migration
  def self.up
    # build a hash of the primary photo id of all the existing galleries
    gals = {}
    Gallery.find(:all).each do |gall|
      gals[gall.id] = gall.primary_photo_id
    end
    add_column    :photos,  :primary, :boolean
    add_column    :photos,   :avatar,  :boolean
    Photo.find(:all).each do |photo|
        photo.update_attributes!(:primary => gals.has_value?(photo.id), :avatar => gals.has_value?(photo.id))
    end
    remove_column :galleries,  :primary_photo_id
    remove_column :people,  :avatar_id
  end

  def self.down
    add_column    :galleries,  :primary_photo_id, :integer
    add_column    :people,  :avatar_id, :integer
    Gallery.find(:all).each do |gall|
      gall.primary_photo_id = gall.photos.find(:first, :conditions => "primary = true").id
      gall.save!
    end
    remove_column :photos,  :primary
    remove_column :photos,  :avatar
  end
end