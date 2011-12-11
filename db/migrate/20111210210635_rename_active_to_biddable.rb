class RenameActiveToBiddable < ActiveRecord::Migration
  def self.up
    rename_column :reqs, :active, :biddable
  end

  def self.down
    rename_column :reqs, :biddable, :active
  end
end
