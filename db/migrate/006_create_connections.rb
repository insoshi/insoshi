class CreateConnections < ActiveRecord::Migration
  def self.up
    create_table :connections do |t|
      t.integer :person_id
      t.integer :connection_id
      t.string :status
      t.timestamp :accepted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :connections
  end
end
