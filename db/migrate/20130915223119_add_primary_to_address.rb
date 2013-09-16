class AddPrimaryToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :primary, :boolean, :default => false
  end
end
