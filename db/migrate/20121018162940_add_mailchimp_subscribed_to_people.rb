class AddMailchimpSubscribedToPeople < ActiveRecord::Migration
  def change
    add_column :people, :mailchimp_subscribed, :boolean, :default => false
  end
end
