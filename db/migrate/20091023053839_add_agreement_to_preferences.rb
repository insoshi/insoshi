class AddAgreementToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :agreement, :text

    Preference.reset_column_information
    preference = Preference.find(:first)
    preference.agreement = "<h2>Member Agreement</h2>Play nice!"
    preference.save
  end

  def self.down
    remove_column :preferences, :agreement
  end
end
