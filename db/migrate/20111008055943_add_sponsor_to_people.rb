class AddSponsorToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :sponsor_id, :integer
  end

  def self.down
    remove_column :people, :sponsor_id
  end
end
