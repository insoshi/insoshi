class MoveAvatarAndPrimaryIdsToPhotoModel < ActiveRecord::Migration
  def self.up
    remove_column :galleries,  :primary_photo_id
    remove_column :people,  :avatar_id
    add_column    :photos,  :primary, :boolean
    add_column    :photos,   :avatar,  :boolean
  end

  def self.down
    add_column    :galleries,  :primary_photo_id, :integer
    add_column    :people,  :avatar_id, :integer
    remove_column :photos,  :primary
    remove_column :photos,  :avatar
  end
end
