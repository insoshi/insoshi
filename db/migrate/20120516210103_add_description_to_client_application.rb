class AddDescriptionToClientApplication < ActiveRecord::Migration
  def self.up
    add_column :client_applications, :description, :string
  end

  def self.down
    remove_column :client_applications, :description
  end
end
