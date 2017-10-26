# == Schema Information
#
# Table name: preferences
#
#  id                              :integer          not null, primary key
#  email_notifications             :boolean          default(FALSE), not null
#  email_verifications             :boolean          default(FALSE), not null
#  created_at                      :datetime
#  updated_at                      :datetime
#  analytics                       :text
#  server_name                     :string(255)
#  app_name                        :string(255)
#  about                           :text
#  demo                            :boolean          default(FALSE)
#  whitelist                       :boolean          default(FALSE)
#  gmail                           :string(255)
#  practice                        :text
#  steps                           :text
#  questions                       :text
#  contact                         :text
#  blog_feed_url                   :string(255)
#  googlemap_api_key               :string(255)
#  agreement                       :text
#  new_member_notification         :string(255)
#  registration_intro              :text
#  default_group_id                :integer
#  topic_refresh_seconds           :integer          default(30), not null
#  groups                          :boolean          default(TRUE), not null
#  alt_signup_link                 :string(255)
#  protected_categories            :boolean          default(FALSE)
#  mailchimp_list_id               :string(255)
#  mailchimp_send_welcome          :boolean          default(TRUE)
#  locale                          :string(255)
#  logout_url                      :string(255)      default("")
#  public_uploads                  :boolean          default(FALSE)
#  display_orgicon                 :boolean          default(TRUE)
#  public_private_bid              :boolean          default(FALSE)
#  openid                          :boolean          default(TRUE)
#  default_deactivated_fee_plan_id :integer
#  show_description                :boolean          default(TRUE)
#  show_neighborhood               :boolean          default(TRUE)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Preference do
  describe "static global preference" do
    it "should prohibit multiple preference objects" do
      @preferences = Preference.new
      @preferences.save.should be_false
      @preferences.errors.full_messages.should include('Attempting to instantiate another Preference object')
    end
  end

  describe "non-boolean attributes" do
    before(:each) do
      @preferences = Preference.new
    end

    it "should have an analytics field" do
      @preferences.should respond_to(:analytics)
    end

    it "should have a blank initial analytics" do
      @preferences.analytics.should be_blank
    end
  end
end
