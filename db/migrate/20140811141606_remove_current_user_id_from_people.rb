class RemoveCurrentUserIdFromPeople < ActiveRecord::Migration
  def change
    remove_column :people, :current_user_id
  end
end
