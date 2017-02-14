class AddMetaToPerson < ActiveRecord::Migration
  def change
    add_column :people, :meta, :text, length: 512
  end
end
