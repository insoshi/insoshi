require "test/unit"
require "rubygems"
require "ruby-debug"
require "active_record"
require "action_controller"
require "action_controller/test_process"

ActiveRecord::Schema.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
ActiveRecord::Base.configurations = true
ActiveRecord::Schema.define(:version => 1) do
  create_table :open_id_authentication_associations, :force => true do |t|
    t.integer :issued, :lifetime
    t.string :handle, :assoc_type
    t.binary :server_url, :secret
  end

  create_table :open_id_authentication_nonces, :force => true do |t|
    t.integer :timestamp, :null => false
    t.string :server_url, :null => true
    t.string :salt, :null => false
  end
  
  create_table :users do |t|
    t.datetime  :created_at
    t.datetime  :updated_at
    t.integer   :lock_version, :default => 0
    t.string    :login
    t.string    :crypted_password
    t.string    :password_salt
    t.string    :persistence_token
    t.string    :single_access_token
    t.string    :perishable_token
    t.string    :openid_identifier
    t.string    :email
    t.string    :first_name
    t.string    :last_name
    t.integer   :login_count, :default => 0, :null => false
    t.integer   :failed_login_count, :default => 0, :null => false
    t.datetime  :last_request_at
    t.datetime  :current_login_at
    t.datetime  :last_login_at
    t.string    :current_login_ip
    t.string    :last_login_ip
  end
end

require "active_record/fixtures"
require "openid"

module Rails
  module VERSION
    STRING = "2.3.5"
  end
end

require File.dirname(__FILE__) + "/../../authlogic/lib/authlogic"
require File.dirname(__FILE__) + "/../../authlogic/lib/authlogic/test_case"
require File.dirname(__FILE__) + '/../../open_id_authentication/lib/open_id_authentication'

# this is partly from open_id_authentication/init.rb
ActionController::Base.send :include, OpenIdAuthentication

require File.dirname(__FILE__) + '/../lib/authlogic_openid'  unless defined?(AuthlogicOpenid)
require File.dirname(__FILE__) + '/libs/user'
require File.dirname(__FILE__) + '/libs/user_session'

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id', :controller => 'session'
end

class SessionController < ActionController::Base
  def default_template(action_name = self.action_name)
    nil
  end
end

class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
  self.fixture_path = File.dirname(__FILE__) + "/fixtures"
  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false
  self.pre_loaded_fixtures = false
  fixtures :all
  setup :activate_authlogic
  
  private
    
    def controller
      @controller ||= create_controller
    end

    def create_controller
      @request = ActionController::TestRequest.new
      @request.path_parameters = {:action => "index", :controller => "session"}
      @response = ActionController::TestResponse.new

      c = SessionController.new
      c.params = {}
      c.request = @request
      c.response = @response
      c.send(:reset_session)
      c.send(:initialize_current_url)

      Authlogic::ControllerAdapters::RailsAdapter.new(c)
    end
    
    def assert_redirecting_to_yahoo(for_param)
      [ /^OpenID identifier="https:\/\/me.yahoo.com\/a\/9W0FJjRj0o981TMSs0vqVxPdmMUVOQ--"/,
        /return_to=\"http:\/\/test.host\/\?#{for_param}=1"/,
        /method="post"/ ].each {|p| assert_match p, @response.headers["WWW-Authenticate"]}
    end

    def assert_not_redirecting
      assert ! @response.headers["WWW-Authenticate"]
    end
end
