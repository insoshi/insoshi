class Admin::PeopleController < ApplicationController
  before_filter :login_required, :admin_required
  active_scaffold :person

  ActiveScaffold.set_defaults do |config|
    config.ignore_columns.add [:created_at, :updated_at, :addresses, :accounts, :activities, :attendee_events, :audits, :blog, :blog_comment_notifications, :categories, :comments, :connection_notifications, :connections, :contacts, :crypted_password, :description, :email_verifications, :event_attendees, :events, :exchanges, :feeds, :identity_url, :last_contacted_at, :message_notifications, :page_views, :photos, :remember_token, :remember_token_expires_at, :requested_contacts, :wall_comment_notifications]
  end
end
