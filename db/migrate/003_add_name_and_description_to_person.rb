class AddNameAndDescriptionToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :name, :string
    add_column :people, :description, :text
  end

  def self.down
    remove_column :people, :description
    remove_column :people, :name
  end
end
