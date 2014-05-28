class AddAvailabilityFlagToFeePlans < ActiveRecord::Migration
  def change
    add_column :fee_plans, :available, :boolean, default: false
  end
end
