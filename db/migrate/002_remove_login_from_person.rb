class RemoveLoginFromPerson < ActiveRecord::Migration
  def self.up
    remove_column :people, :login
  end

  def self.down
    add_column :people, :login, :string
  end
end
