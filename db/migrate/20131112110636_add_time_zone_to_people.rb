class AddTimeZoneToPeople < ActiveRecord::Migration
  def change
    add_column :people, :time_zone, :string
  end
end
