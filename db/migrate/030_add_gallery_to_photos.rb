class AddGalleryToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :gallery_id, :integer
    add_column :photos, :title, :string
    remove_column :photos, :primary
  end

  def self.down
    remove_column :photos, :gallery_id
    remove_column :photos, :title
    add_column :phots, :primary
  end
end
