class AddPictureForToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :picture_for, :string
  end
end
