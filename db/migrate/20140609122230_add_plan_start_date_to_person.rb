class AddPlanStartDateToPerson < ActiveRecord::Migration
  def change
    add_column :people, :plan_started_at, :datetime
  end
end
