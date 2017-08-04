class RemoveHighresFromPhotos < ActiveRecord::Migration
  def up
    remove_column :photos, :highres
  end

  def down
    add_column :photos, :highres, :boolean, default: true
  end
end
