class AddLocaleToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :locale, :string
  end
end
