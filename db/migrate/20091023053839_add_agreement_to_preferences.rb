class AddAgreementToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :agreement, :text
  end

  def self.down
    remove_column :preferences, :agreement
  end
end
