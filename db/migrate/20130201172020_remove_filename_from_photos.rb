class RemoveFilenameFromPhotos < ActiveRecord::Migration
  def up
    remove_column :photos, :filename
  end

  def down
    add_column :photos, :filename, :string
  end
end
