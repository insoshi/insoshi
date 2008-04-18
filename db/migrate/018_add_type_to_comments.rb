class AddTypeToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :type, :string
  end

  def self.down
    remove_column :comments, :type
  end
end
