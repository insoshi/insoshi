class AddGroupToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :group_id, :integer
  end

  def self.down
    remove_column :activities, :group_id
  end
end
