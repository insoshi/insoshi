class AddLatAndLongToAddress < ActiveRecord::Migration
  def self.up
    add_column :addresses, :lat, :float # Postgres doesn't have :double
    add_column :addresses, :lng, :float
  end

  def self.down
    remove_column :addresses, :lat
    remove_column :addresses, :lng
  end
end
