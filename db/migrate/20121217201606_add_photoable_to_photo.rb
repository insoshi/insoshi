class AddPhotoableToPhoto < ActiveRecord::Migration
  def self.up
    add_column :photos, :photoable_id, :integer
    add_column :photos, :photoable_type, :string
  end
end
