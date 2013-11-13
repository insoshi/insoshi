class AddDateStyleToPeople < ActiveRecord::Migration
  def change
    add_column :people, :date_style, :string
  end
end
