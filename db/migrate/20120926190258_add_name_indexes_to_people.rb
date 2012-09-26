class AddNameIndexesToPeople < ActiveRecord::Migration
  def change
  	add_index :people, :name
  	add_index :people, :business_name
  end
end
