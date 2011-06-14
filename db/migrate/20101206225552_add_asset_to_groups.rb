class AddAssetToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :asset, :string
  end

  def self.down
    remove_column :groups, :asset
  end
end
