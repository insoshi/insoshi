require 'spec_helper'
require 'rack/test'
require 'oauth/rack/oauth_filter'
require 'multi_json'
require 'forwardable'

class OAuthEcho
  def call(env)
    response = {}
    response[:oauth_token]        = env["oauth.token"].token            if env["oauth.token"]
    response[:client_application] = env["oauth.client_application"].key if env["oauth.client_application"]
    response[:oauth_version]      = env["oauth.version"]                if env["oauth.version"]
    response[:strategies]         = env["oauth.strategies"]             if env["oauth.strategies"]
     [200, { "Accept" => "application/json" }, [MultiJson.encode(response)]]
  end
end

describe OAuth::Rack::OAuthFilter do
  include Rack::Test::Methods

  def app
    @app ||= OAuth::Rack::OAuthFilter.new(OAuthEcho.new)
  end

  it "should pass through without oauth" do
    get '/'
    last_response.should be_ok
    response = MultiJson.decode(last_response.body)
    response.should == {}
  end

  it "should sign with consumer" do
    get '/',{},{"HTTP_AUTHORIZATION"=>'OAuth oauth_consumer_key="my_consumer", oauth_nonce="amrLDyFE2AMztx5fOYDD1OEqWps6Mc2mAR5qyO44Rj8", oauth_signature="KCSg0RUfVFUcyhrgJo580H8ey0c%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1295039581", oauth_version="1.0"'}
    last_response.should be_ok
    response = MultiJson.decode(last_response.body)
    response.should == {"client_application" => "my_consumer", "oauth_version"=>1, "strategies"=>["two_legged"]}
  end

  it "should sign with oauth 1 access token" do
    client_application = ClientApplication.new "my_consumer"
    ClientApplication.stub!(:find_by_key).and_return(client_application)
    client_application.tokens.stub!(:first).and_return(AccessToken.new("my_token"))
    get '/',{},{"HTTP_AUTHORIZATION"=>'OAuth oauth_consumer_key="my_consumer", oauth_nonce="oiFHXoN0172eigBBUfgaZLdQg7ycGekv8iTdfkCStY", oauth_signature="y35B2DqTWaNlzNX0p4wv%2FJAGzg8%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1295040394", oauth_token="my_token", oauth_version="1.0"'}
    last_response.should be_ok
    response = MultiJson.decode(last_response.body)
    response.should == {"client_application" => "my_consumer", "oauth_token"=>"my_token","oauth_version"=>1, "strategies"=>["oauth10_token","token","oauth10_access_token"]}
  end

  it "should sign with oauth 1 request token" do
    client_application = ClientApplication.new "my_consumer"
    ClientApplication.stub!(:find_by_key).and_return(client_application)
    client_application.tokens.stub!(:first).and_return(RequestToken.new("my_token"))
    get '/',{},{"HTTP_AUTHORIZATION"=>'OAuth oauth_consumer_key="my_consumer", oauth_nonce="oiFHXoN0172eigBBUfgaZLdQg7ycGekv8iTdfkCStY", oauth_signature="y35B2DqTWaNlzNX0p4wv%2FJAGzg8%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1295040394", oauth_token="my_token", oauth_version="1.0"'}
    last_response.should be_ok
    response = MultiJson.decode(last_response.body)
    response.should == {"client_application" => "my_consumer", "oauth_token"=>"my_token","oauth_version"=>1, "strategies"=>["oauth10_token","oauth10_request_token"]}
  end

  describe "OAuth2" do
    describe "token given through a HTTP Auth Header" do
      context "authorized and non-invalidated token" do
        it "authenticates" do
          get '/', {}, { "HTTP_AUTHORIZATION" => "OAuth valid_token" }
          last_response.should be_ok
          response = MultiJson.decode(last_response.body)
          response.should == { "oauth_token" => "valid_token", "oauth_version" => 2, "strategies"=> ["oauth20_token", "token"] }
        end
      end

      context "non-authorized token" do
        it "doesn't authenticate" do
          get '/', {}, { "HTTP_AUTHORIZATION" => "OAuth not_authorized" }
          last_response.should be_ok
          response = MultiJson.decode(last_response.body)
          response.should == {}
        end
      end

      context "authorized and invalidated token" do
        it "doesn't authenticate with an invalidated token" do
          get '/', {}, { "HTTP_AUTHORIZATION" => "OAuth invalidated" }
          last_response.should be_ok
          response = MultiJson.decode(last_response.body)
          response.should == {}
        end
      end
    end

    describe "token given through a HTTP Auth Header following the OAuth2 pre draft" do
      context "authorized and non-invalidated token" do
        it "authenticates" do
          get '/', {}, { "HTTP_AUTHORIZATION" => "Token valid_token" }
          last_response.should be_ok
          response = MultiJson.decode(last_response.body)
          response.should == { "oauth_token" => "valid_token", "oauth_version" => 2, "strategies"=> ["oauth20_token", "token"] }
        end
      end

      context "non-authorized token" do
        it "doesn't authenticate" do
          get '/', {}, { "HTTP_AUTHORIZATION" => "Token not_authorized" }
          last_response.should be_ok
          response = MultiJson.decode(last_response.body)
          response.should == {}
        end
      end

      context "authorized and invalidated token" do
        it "doesn't authenticate with an invalidated token" do
          get '/', {}, { "HTTP_AUTHORIZATION" => "Token invalidated" }
          last_response.should be_ok
          response = MultiJson.decode(last_response.body)
          response.should == {}
        end
      end
    end

    describe "token given through a query parameter" do
      context "authorized and non-invalidated token" do
        it "authenticates" do
          get '/?oauth_token=valid_token'
          last_response.should be_ok
          response = MultiJson.decode(last_response.body)
          response.should == { "oauth_token" => "valid_token", "oauth_version" => 2, "strategies"=> ["oauth20_token", "token"] }
        end
      end

      context "non-authorized token" do
        it "doesn't authenticate" do
          get '/?oauth_token=not_authorized'
          last_response.should be_ok
          response = MultiJson.decode(last_response.body)
          response.should == {}
        end
      end

      context "authorized and invalidated token" do
        it "doesn't authenticate with an invalidated token" do
          get '/?oauth_token=invalidated'
          last_response.should be_ok
          response = MultiJson.decode(last_response.body)
          response.should == {}
        end
      end
    end

    describe "token given through a post parameter" do
      context "authorized and non-invalidated token" do
        it "authenticates" do
          post '/', :oauth_token => 'valid_token'
          last_response.should be_ok
          response = MultiJson.decode(last_response.body)
          response.should == { "oauth_token" => "valid_token", "oauth_version" => 2, "strategies"=> ["oauth20_token", "token"] }
        end
      end

      context "non-authorized token" do
        it "doesn't authenticate" do
          post '/', :oauth_token => 'not_authorized'
          last_response.should be_ok
          response = MultiJson.decode(last_response.body)
          response.should == {}
        end
      end

      context "authorized and invalidated token" do
        it "doesn't authenticate with an invalidated token" do
          post '/', :oauth_token => 'invalidated'
          last_response.should be_ok
          response = MultiJson.decode(last_response.body)
          response.should == {}
        end
      end
    end
  end


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
  class AccessToken < OauthToken ; end
  class RequestToken < OauthToken ; end

  class OauthNonce
    # Always remember
    def self.remember(nonce,timestamp)
      true
    end
  end

end