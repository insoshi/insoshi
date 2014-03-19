class CreateForms < ActiveRecord::Migration
  def change
    create_table :forms do |t|
      t.string :title
      t.string :text
      t.string :message_type

      t.timestamps
    end
  end
end
