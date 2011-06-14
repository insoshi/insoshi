class AddRolesMaskToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :roles_mask, :integer
  end

  def self.down
    remove_column :memberships, :roles_mask
  end
end
