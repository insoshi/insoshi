class AddCategoryIntroToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :category_intro, :text
  end
end
