class AddLoginIntroToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :login_intro, :text
  end
end
