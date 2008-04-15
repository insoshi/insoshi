class AddDefaultPreferences < ActiveRecord::Migration
  def self.up
    Preference.create!(:email_notifications => false)
  end

  def self.down
    Preference.find(:all).each {|p| p.destroy}
  end
end
