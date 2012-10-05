class AddProtectedCategoriesToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :protected_categories, :boolean, :default => false
  end
end
