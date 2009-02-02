class AddTwitterNamePeople < ActiveRecord::Migration
  def self.up
    add_column :people, :twitter_name, :string
  end

  def self.down
    remove_column :people, :twitter_name
  end
end
