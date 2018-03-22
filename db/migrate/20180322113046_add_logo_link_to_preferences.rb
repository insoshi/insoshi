# Field to store the logo link
class AddLogoLinkToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :logo_link, :string
  end
end
