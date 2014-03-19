class AddLangToForms < ActiveRecord::Migration
  def change
    add_column :forms, :lang, :string
  end
end
