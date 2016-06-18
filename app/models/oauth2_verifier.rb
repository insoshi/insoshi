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
#  created_at            :datetime
#  updated_at            :datetime
#  callback_url          :string(255)
#  verifier              :string(20)
#  scope                 :string(255)
#  expires_at            :datetime
#  group_id              :integer
#

class Oauth2Verifier < OauthToken
  validates_presence_of :person
  attr_accessor :state

  def exchange!(params={})
    OauthToken.transaction do
      token = Oauth2Token.create! :person=>person,:client_application=>client_application, :scope=>scope
      invalidate!
      token
    end
  end

  def code
    token
  end

  def redirect_url
    callback_url
  end

  def to_query
    q = "code=#{token}"
    q << "&state=#{URI.escape(state)}" if @state
    q
  end

  protected

  def generate_keys
    self.token = OAuth::Helper.generate_key(20)[0,20]
    self.expires_at = 10.minutes.from_now
    self.authorized_at = Time.now
  end

end
