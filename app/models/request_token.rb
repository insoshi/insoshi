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

class RequestToken < OauthToken
  
  attr_accessor :provided_oauth_verifier
  
  def authorize!(person)
    return false if authorized?
    self.person = person
    self.authorized_at = Time.now
    self.verifier=OAuth::Helper.generate_key(20)[0,20] unless oauth10?
    self.save
  end


  def exchange!
    return false unless authorized?
    return false unless oauth10? || verifier==provided_oauth_verifier
    
    RequestToken.transaction do
      access_token = AccessToken.create(:person => person, :scope => "", :client_application => client_application)
      capabilities.each do |capability|
        unless capability.invalidated? 
          access_token.capabilities << capability
        end
      end
      invalidate!
      access_token
    end
  end
  
  def to_query
    if oauth10?
      super
    else
      "#{super}&oauth_callback_confirmed=true"
    end
  end
  
  def oob?
    callback_url.nil? || callback_url.downcase =='oob'
  end
  
  def oauth10?
    (defined? OAUTH_10_SUPPORT) && OAUTH_10_SUPPORT && self.callback_url.blank?
  end

end
