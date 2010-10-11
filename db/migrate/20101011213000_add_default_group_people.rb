class AddDefaultGroupPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :default_group_id, :integer
  end

  def self.down
    remove_column :people, :default_group_id
  end
end
