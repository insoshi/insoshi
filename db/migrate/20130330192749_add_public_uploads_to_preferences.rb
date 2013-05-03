class AddPublicUploadsToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :public_uploads, :boolean, :default => false
  end
end
