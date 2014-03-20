class CreateSystemMessageTemplates < ActiveRecord::Migration
  def change
    create_table :system_message_templates do |t|
      t.string :title
      t.string :text
      t.string :message_type
      t.string :lang

      t.timestamps
    end
  end
end
