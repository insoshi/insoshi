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

class AccessToken<OauthToken
  validates_presence_of :person
  before_create :set_authorized_at
  
  # Implement this to return a hash or array of the capabilities the access token has
  # This is particularly useful if you have implemented user defined permissions.
  # def capabilities
  #   {:invalidate=>"/oauth/invalidate",:capabilities=>"/oauth/capabilities"}
  # end
 
  protected 
  
  def set_authorized_at
    self.authorized_at=Time.now
  end
end
