require "authlogic_openid/version"
require "authlogic_openid/acts_as_authentic"
require "authlogic_openid/session"

ActiveRecord::Base.send(:include, AuthlogicOpenid::ActsAsAuthentic)
Authlogic::Session::Base.send(:include, AuthlogicOpenid::Session)