class AddVisibleToPerson < ActiveRecord::Migration
  def change
    add_column :people, :visible, :boolean, default: true
  end
end
