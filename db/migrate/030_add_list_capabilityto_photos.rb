class AddListCapabilitytoPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :position, :integer
  end

  def self.down
    remove_column :photos, :position
  end
end
