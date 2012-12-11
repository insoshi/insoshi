class AddPictureToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :picture, :string
  end
end
