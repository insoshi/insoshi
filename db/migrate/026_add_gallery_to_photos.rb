class AddGalleryToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :gallery_id, :integer
  end

  def self.down
    remove_column :photos, :gallery_id
  end
end
