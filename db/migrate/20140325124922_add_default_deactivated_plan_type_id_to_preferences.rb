class AddDefaultDeactivatedPlanTypeIdToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :default_deactivated_plan_type_id, :integer
  end
end
