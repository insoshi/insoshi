# == Schema Information
#
# Table name: preferences
#
#  id                              :integer          not null, primary key
#  email_notifications             :boolean          default(FALSE), not null
#  email_verifications             :boolean          default(FALSE), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
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

class Preference < ActiveRecord::Base
  attr_accessible :app_name, :server_name,
                  :new_member_notification,
                  :email_notifications, :email_verifications, :analytics,
                  :about, :demo, :whitelist, :gmail,
                  :practice, :steps, :questions, :contact,
                  :registration_intro,
                  :agreement,
                  :protected_categories,
                  :blog_feed_url,
                  :googlemap_api_key,
                  :default_group_id, :display_orgicon,
                  :default_deactivated_fee_plan_id
  attr_accessible *attribute_names, :as => :admin

  validate :enforce_singleton, :on => :create

  belongs_to :default_group, :class_name => "Group", :foreign_key => "default_group_id"

  # default profile picture and default group picture
  has_many :photos, :as => :photoable, :dependent => :destroy, :order => 'created_at'

  # Can we send mail with the present configuration?
  def can_send_email?
    not (ENV['SMTP_DOMAIN'].blank? or ENV['SMTP_SERVER'].blank?)
  end

  def enforce_singleton
    unless Preference.all.count == 0
      errors.add :base, "Attempting to instantiate another Preference object"
    end
  end

  def using_email?
    email_notifications? or email_verifications?
  end

  def default_profile_picture
    self.photos.find_by_picture_for('profile')
  end

  def default_group_picture
    self.photos.find_by_picture_for('group')
  end

  alias_attribute :faq, :questions

  class << self

    def profile_image version = nil
      unless Preference.first.default_profile_picture.blank?
        if version
          Preference.first.default_profile_picture.picture_url(version)
        else
          Preference.first.default_profile_picture.picture_url
        end
      end
    end

    def group_image version = nil
      unless Preference.first.default_group_picture.blank?
        if version
          Preference.first.default_group_picture.picture_url(version)
        else
          Preference.first.default_group_picture.picture_url
        end
      end
    end

  end

  private
    def decrypt(password)
      k = LocalEncryptionKey.find(:first)
      Crypto::Key.from_local_key_value(k.rsa_private_key).decrypt(password)
    end

    def self.encrypt(password)
      k = LocalEncryptionKey.find(:first)
      Crypto::Key.from_local_key_value(k.rsa_public_key).encrypt(password)
    end

    # Encrypts the password with the user salt
    def encrypt(password)
      self.class.encrypt(password)
    end
end
