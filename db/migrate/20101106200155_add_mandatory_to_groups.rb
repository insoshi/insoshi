class AddMandatoryToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :mandatory, :boolean, :default => false
  end

  def self.down
    remove_column :groups, :mandatory
  end
end
