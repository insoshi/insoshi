class AddFormSignupFieldIdToPersonMetadata < ActiveRecord::Migration
  def change
    add_column :person_metadata, :form_signup_field_id, :integer
  end
end
