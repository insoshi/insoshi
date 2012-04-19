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
    secret = access_token.respond_to?(:secret) ? access_token.secret : nil

    if user
      user.consumer_tokens.where(:_type=>self.to_s,:token=>access_token.token).first ||
        self.create!(:_type=>self.to_s,:token=>access_token.token, :secret=>secret, :user=>user)
    else
      user = User.where("consumer_tokens._type"=>self.to_s,"consumer_tokens.token"=>access_token.token).first
      if user
        user.consumer_tokens.detect{|t| t.token==access_token.token && t.is_a?(self)}
      else
        user = User.new
        self.create!(:_type=>self.to_s,:token=>access_token.token, :secret=>secret, :user=>user)
        user.save!
        user.consumer_tokens.last
      end
    end
  end

end
