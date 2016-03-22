# == Schema Information
#
# Table name: oauth_tokens
#
#  id                    :integer          not null, primary key
#  person_id             :integer
#  type                  :string(20)
#  client_application_id :integer
#  token                 :string(50)
#  secret                :string(50)
#  authorized_at         :datetime
#  invalidated_at        :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  callback_url          :string(255)
#  verifier              :string(20)
#  scope                 :string(255)
#  expires_at            :datetime
#  group_id              :integer
#

class OauthToken < ActiveRecord::Base
  belongs_to :client_application
  belongs_to :person
  has_many :capabilities
  validates_uniqueness_of :token
  validates_presence_of :client_application, :token
  before_validation :generate_keys, :on => :create

  after_create :add_capabilities
  
  def add_capabilities
    if ::OauthScope.all_exist?(self.scope)
      self.scope.split.each do |s|
        self.capabilities << Capability.create!(:scope => s)
      end
    end
  end

  def invalidated?
    invalidated_at != nil
  end
  
  def invalidate!
    update_attribute(:invalidated_at, Time.now)
  end
  
  def authorized?
    authorized_at != nil && !invalidated?
  end
    
  def to_query
    "oauth_token=#{token}&oauth_token_secret=#{secret}"
  end

  def authorized_for?(requested_amount)
    !invalidated? && capabilities.detect {|capability| capability.authorized_for?(requested_amount)}
  end

  def single_payment?
    capabilities.detect {|capability| capability.single_payment?}
  end

  protected
  
  def generate_keys
    self.token = OAuth::Helper.generate_key(40)[0,40]
    self.secret = OAuth::Helper.generate_key(40)[0,40]
  end
end
