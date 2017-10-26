class CreateAccountImports < ActiveRecord::Migration
  def change
    create_table :account_imports do |t|
      t.integer :person_id, null: false
      t.string :file, null:true
      t.boolean :successful, default: false

      t.timestamps
    end
  end
end
