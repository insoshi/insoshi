class AddHighresToPhotos < ActiveRecord::Migration
  def up
    add_column :photos, :highres, :boolean, default: true

    Photo.all.each do |photo|
      photo.highres = false
      photo.save
    end
  end

  def down
    remove_column :photos, :highres
  end
end
