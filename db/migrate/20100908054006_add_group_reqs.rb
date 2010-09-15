class AddGroupReqs < ActiveRecord::Migration
  def self.up
    add_column :reqs, :group_id, :integer
  end

  def self.down
    remove_column :reqs, :group_id
  end
end
