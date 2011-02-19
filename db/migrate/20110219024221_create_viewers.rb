class CreateViewers < ActiveRecord::Migration
  def self.up
    create_table :viewers do |t|
      t.integer :topic_id
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :viewers
  end
end
