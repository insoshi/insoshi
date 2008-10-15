class MoveThumbnails < ActiveRecord::Migration

  class Photo < ActiveRecord::Base
  end

  ATTRIBUTES = %w[parent_id content_type filename thumbnail size width
                  height created_at updated_at]  
  def self.up
    # Move thumbnails to their new table.
    old_thumbnails = Photo.find(:all, :conditions => "thumbnail IS NOT NULL")
    old_thumbnails.each do |old_thumbnail|
      thumbnail = Thumbnail.new
      ATTRIBUTES.each do |attribute|
        thumbnail[attribute] = old_thumbnail.send(attribute)
      end
      thumbnail.save!
      old_thumbnail.destroy
    end
    remove_column :photos, :thumbnail
  end

  def self.down
    add_column :photos, :thumbnail, :string
    thumbnails = Thumbnail.find(:all)
    thumbnails.each do |thumbnail|
      photo = Photo.new
      ATTRIBUTES.each do |attribute|
        photo[attribute] = thumbnail.send(attribute)
      end
      photo.save!
      thumbnail.destroy
    end
  end
end
