class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.integer :person_id
      t.integer :parent_id
      t.string  :content_type
      t.string  :filename
      t.string  :thumbnail
      t.integer :size
      t.integer :width
      t.integer :height
      t.boolean :primary

      t.timestamps
    end
    add_index :photos, :person_id
    add_index :photos, :parent_id
  end

  def self.down
    drop_table :photos
  end
end