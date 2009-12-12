class AddAgreementToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :agreement, :text, :default => "<h2>Member Agreement</h2>Play nice!"
  end

  def self.down
    remove_column :preferences, :agreement
  end
end
