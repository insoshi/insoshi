class AddMailchimpListIdToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :mailchimp_list_id, :string
  end
end
