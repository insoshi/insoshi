class AddCurrentUserIdToPeople < ActiveRecord::Migration
  def change
    add_column :people, :current_user_id, :integer
  end
end
