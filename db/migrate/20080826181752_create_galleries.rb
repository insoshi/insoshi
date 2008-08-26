class CreateGalleries < ActiveRecord::Migration
  def self.up
    create_table :galleries do |t|
      t.integer :person_id
      t.string :title
      t.string :description
      t.integer :photos_count, :null => false, :default => 0
      t.integer :primary_photo_id
      t.timestamps
    end
  end
  def self.down
    drop_table :galleries
  end
end
