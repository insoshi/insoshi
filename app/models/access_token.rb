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

class AccessToken < OauthToken
  validates_presence_of :person, :secret
  before_create :set_authorized_at
  
  # Implement this to return a hash or array of the capabilities the access token has
  # This is particularly useful if you have implemented user defined permissions.
  # def capabilities
  #   {:invalidate=>"/oauth/invalidate",:capabilities=>"/oauth/capabilities"}
  # end
  
  protected 
  
  def set_authorized_at
    self.authorized_at = Time.now
  end
end
