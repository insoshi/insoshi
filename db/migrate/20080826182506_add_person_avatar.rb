class AddPersonAvatar < ActiveRecord::Migration
  def self.up
    add_column :people, :avatar_id, :integer
  end

  def self.down
    remove_column :people, :avatar_id
  end
end
