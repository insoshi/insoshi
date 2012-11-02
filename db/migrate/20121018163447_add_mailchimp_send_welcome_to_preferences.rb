class AddMailchimpSendWelcomeToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :mailchimp_send_welcome, :boolean, :default => true
  end
end
