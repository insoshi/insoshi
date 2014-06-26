class AddDefaultDeactivatedPlanTypeIdToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :default_deactivated_fee_plan_id, :integer
  end
end
