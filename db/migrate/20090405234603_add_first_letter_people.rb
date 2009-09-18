class AddFirstLetterPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :first_letter, :string
  end

  def self.down
    remove_column :people, :first_letter
  end
end
