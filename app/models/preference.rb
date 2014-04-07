# == Schema Information
# Schema version: 20090216032013
#
# Table name: preferences
#
#  id                                    :integer(4)      not null, primary key
#  domain                                :string(255)     default(""), not null
#  smtp_server                           :string(255)     default(""), not null
#  email_notifications                   :boolean(1)      not null
#  email_verifications                   :boolean(1)      not null
#  created_at                            :datetime
#  updated_at                            :datetime
#  analytics                             :text
#  server_name                           :string(255)
#  app_name                              :string(255)
#  about                                 :text
#  demo                                  :boolean(1)
#  whitelist                             :boolean(1)
#  gmail                                 :string(255)
#  exception_notification                :string(255)
#  registration_notification             :boolean(1)
#  practice                              :text
#  steps                                 :text
#  questions                             :text
#  memberships                           :text
#  contact                               :text
#  twitter_name                          :string(255)
#  crypted_twitter_password              :string(255)
#  twitter_api                           :string(255)
#  twitter_oauth_consumer_key            :string(255)
#  crypted_twitter_oauth_consumer_secret :string(255)
#  display_orgicon                       :boolean(1)      default(true)

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
                  :default_group_id, :display_orgicon
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
