class AddAltSignupLinkToPreferences < ActiveRecord::Migration
  def change
  	add_column :preferences, :alt_signup_link, :string
  end
end
