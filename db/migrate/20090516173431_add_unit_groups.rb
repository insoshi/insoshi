class AddUnitGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :unit, :string
  end

  def self.down
    remove_column :groups, :unit
  end
end
