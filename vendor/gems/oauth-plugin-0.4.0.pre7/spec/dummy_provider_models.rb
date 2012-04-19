# Dummy implementation
class ClientApplication
  attr_accessor :key

  def self.find_by_key(key)
    ClientApplication.new(key)
  end

  def initialize(key)
    @key = key
  end

  def tokens
    @tokens||=[]
  end

  def secret
    "secret"
  end
end

class OauthToken
  attr_accessor :token

  def self.first(conditions_hash)
    case conditions_hash[:conditions].last
    when "not_authorized", "invalidated"
      nil
    else
      OauthToken.new(conditions_hash[:conditions].last)
    end
  end

  def initialize(token)
    @token = token
  end

  def secret
    "secret"
  end
end

class Oauth2Token < OauthToken ; end
class Oauth2Verifier < OauthToken ; end
class AccessToken < OauthToken ; end
class RequestToken < OauthToken ; end

class OauthNonce
  # Always remember
  def self.remember(nonce,timestamp)
    true
  end
end
