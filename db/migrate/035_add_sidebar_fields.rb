class AddSidebarFields < ActiveRecord::Migration
  def self.up
    add_column :preferences, :sidebar_title, :string
    add_column :preferences, :sidebar_body, :text
  end

  def self.down
    remove_column :preferences, :sidebar_title
    remove_column :preferences, :sidebar_body
  end
end
