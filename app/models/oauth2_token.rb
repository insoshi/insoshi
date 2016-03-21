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

class Oauth2Token < AccessToken
  attr_accessor :state
  def as_json(options={})
    d = {:access_token=>token, :token_type => 'bearer'}
    d[:expires_in] = expires_in if expires_at
    d
  end

  def to_query
    q = "access_token=#{token}&token_type=bearer"
    q << "&state=#{URI.escape(state)}" if @state
    q << "&expires_in=#{expires_in}" if expires_at
    q << "&scope=#{URI.escape(scope)}" if scope
    q
  end

  def expires_in
    expires_at.to_i - Time.now.to_i
  end
end
