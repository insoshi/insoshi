class AddSignupFieldPrefs < ActiveRecord::Migration
  def up
    add_column :preferences, :show_description, :boolean, default: true
    add_column :preferences, :show_neighborhood, :boolean, default: true
  end

  def down
    remove_column :preferences, :show_description
    remove_column :preferences, :show_neighborhood
  end
end
