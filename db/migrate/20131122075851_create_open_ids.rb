class CreateOpenIds < ActiveRecord::Migration
  def change
    create_table :open_ids do |t|
      t.boolean :open_id, :default => true

      t.timestamps
    end
  end
end
