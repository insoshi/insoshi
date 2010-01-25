class AddContentPagesToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :practice, :text
    add_column :preferences, :steps, :text
    add_column :preferences, :questions, :text
    add_column :preferences, :contact, :text
  end

  def self.down
    remove_column :preferences, :practice
    remove_column :preferences, :steps
    remove_column :preferences, :questions
    remove_column :preferences, :contact
  end
end
