class AddJuniorAdminToPeople < ActiveRecord::Migration
  def change
    add_column :people, :junior_admin, :boolean, default: false
  end
end
