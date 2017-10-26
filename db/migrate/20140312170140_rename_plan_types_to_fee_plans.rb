class RenamePlanTypesToFeePlans < ActiveRecord::Migration
  def up
    rename_table :plan_types, :fee_plans
    rename_column :people, :plan_type_id, :fee_plan_id
  end

  def down
    rename_column :people, :fee_plan_id, :plan_type_id
    rename_table :fee_plans, :plan_types
  end
end
