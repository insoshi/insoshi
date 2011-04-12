require 'oauth/models/consumers/token'
class ConsumerToken
  include Mongoid::Document
  include Mongoid::Timestamps
  include Oauth::Models::Consumers::Token
  
  # You can safely remove this callback if you don't allow login from any of your services
  before_create :create_user

  field :token, :type => String
  field :secret, :type => String

  index :token

  # Add the following to your user model:
  # 
  #   embeds_many :consumer_tokens  
  #   index "consumer_tokens.token"
  #
  embedded_in :user, :inverse_of => :consumer_tokens

  def self.find_or_create_from_access_token(user,access_token)
    if user
      user.consumer_tokens.first(:conditions=>{:_type=>self.to_s,:token=>access_token.token}) ||
        user.consumer_tokens.create!(:_type=>self.to_s,:token=>access_token.token, :secret=>access_token.secret)
    else
      # Is there a better way of doing this in mongoid?
      # Please submit a patch
      user = User.first(:conditions=>{:_type=>self.to_s,"consumer_tokens.token"=>access_token.token})
      if user
        user.consumer_tokens.detect{|t| t.token==access_token.token && t.is_a?(self)} 
      else
        user = User.create
        user.consumer_tokens.create!(:_type=>self.to_s,:token=>access_token.token, :secret=>access_token.secret)
      end
    end
  end

end
