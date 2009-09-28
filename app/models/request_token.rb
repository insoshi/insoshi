# == Schema Information
# Schema version: 20090216032013
#
# Table name: oauth_tokens
#
#  id                    :integer(4)      not null, primary key
#  person_id             :integer(4)      
#  type                  :string(20)      
#  client_application_id :integer(4)      
#  token                 :string(50)      
#  secret                :string(50)      
#  authorized_at         :datetime        
#  invalidated_at        :datetime        
#  created_at            :datetime        
#  updated_at            :datetime        
#

class RequestToken < OauthToken

  attr_accessor :provided_oauth_verifier
  
  def authorize!(person)
    return false if authorized?
    #self.person=person
    self.user=person
    self.authorized_at=Time.now
    self.verifier=OAuth::Helper.generate_key(16)[0,20] unless oauth10?
    self.save
  end
  
  def exchange!
    return false unless authorized?
    return false unless oauth10? || verifier==provided_oauth_verifier

    RequestToken.transaction do
      #access_token=AccessToken.create(:person => person, :client_application => client_application)
      access_token=AccessToken.create(:user => user, :client_application => client_application)
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
    self.callback_url=='oob'
  end
  
  def oauth10?
    (defined? OAUTH_10_SUPPORT) && OAUTH_10_SUPPORT && self.callback_url.blank?
  end

end
