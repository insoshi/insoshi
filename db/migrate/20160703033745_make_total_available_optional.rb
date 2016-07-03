class MakeTotalAvailableOptional < ActiveRecord::Migration
  def up
   change_column_default :offers, :total_available, 1 
  end

  def down
    change_column_default :offers, :total_available, nil
  end
end
