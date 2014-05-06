class AddOptionsToFormSignupFields < ActiveRecord::Migration
  def change
    add_column :form_signup_fields, :options, :string
  end
end
