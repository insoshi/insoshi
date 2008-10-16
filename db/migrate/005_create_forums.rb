class CreateForums < ActiveRecord::Migration
  
  # Declare the Forum model here so that the code below works even if you
  # change app/models/forum.rb by (say) adding validations.
  class Forum < ActiveRecord::Base
  end
  
  def self.up
    create_table :forums do |t|
      t.string :name
      t.text :description
      t.integer :topics_count, :null => false, :default => 0

      t.timestamps
    end
    Forum.create!(:name => "Discussion forum",
                  :description => "The main forum")
  end

  def self.down
    drop_table :forums
  end
end
