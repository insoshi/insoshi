class AddZipcodePeople < ActiveRecord::Migration
  def self.up
    add_column :people, :zipcode, :string
  end

  def self.down
    remove_column :people, :zipcode
  end
end
