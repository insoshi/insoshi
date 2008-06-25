class CreateHasEasyThings < ActiveRecord::Migration
  def self.up
    create_table :has_easy_things do |t|
      t.string  :model_type, :null => false
      t.integer :model_id, :null => false
      t.string  :context
      t.string  :name, :null => false
      t.string  :value
      t.timestamps
    end
  end

  def self.down
    drop_table :has_easy_things
  end
end