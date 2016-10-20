class AddUpdateCardToPeople < ActiveRecord::Migration
  def change
    add_column :people, :update_card, :boolean, default: false
  end
end
