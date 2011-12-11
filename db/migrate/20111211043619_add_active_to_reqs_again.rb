class AddActiveToReqsAgain < ActiveRecord::Migration
  def self.up
    add_column :reqs, :active, :boolean, :default => false
  end

  def self.down
    remove_column :reqs, :active
  end
end
