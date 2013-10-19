class AddRolesMaskToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :roles_mask, :integer
  end
end
