class AddAdminContactToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :admin_contact_id, :integer
  end
end
