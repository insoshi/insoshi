class CreatePersonMetadata < ActiveRecord::Migration
  def change
    create_table :person_metadata do |t|
      t.string :key
      t.string :value
      t.integer :person_id

      t.timestamps
    end
  end
end
