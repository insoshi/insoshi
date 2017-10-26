class CreateFormSignupFields < ActiveRecord::Migration
  def change
    create_table :form_signup_fields do |t|
      t.string :key
      t.string :title
      t.boolean :mandatory, default: false
      t.string :field_type
      t.integer :order

      t.timestamps
    end
  end
end
