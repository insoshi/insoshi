class CreateStates < ActiveRecord::Migration
  def self.up
      create_table :states do |t|
        t.string :name,         :null => false, :limit => 25
        t.string :abbreviation, :null => false, :limit => 2
        t.timestamps
      end
  end

  def self.down
    drop_table :states
  end

end
