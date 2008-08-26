class UpdatePhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :avatar, :boolean
    add_column :photos, :gallery_id, :integer
    add_column :photos, :title, :string
    add_column :photos, :position, :integer
  end

  def self.down
    remove_column :photos, :position
    remove_column :photos, :title
    remove_column :photos, :gallery_id
    remove_column :photos, :avatar
  end
end
