class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :type,       length: 25
      t.string :record,     length: 100
      t.integer :person_id
      t.integer :group_id

      t.timestamps
    end
  end
end
