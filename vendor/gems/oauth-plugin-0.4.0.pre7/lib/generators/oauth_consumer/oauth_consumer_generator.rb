require 'rails/generators/migration'
require 'rails/generators/active_record'

class OauthConsumerGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)
  
  hook_for :orm
    
  def copy_models
    template 'oauth_config.rb',   File.join('config', 'initializers', 'oauth_consumers.rb')
  end
  
  def copy_controller
    template 'controller.rb', File.join('app', 'controllers', 'oauth_consumers_controller.rb')
  end
  
  hook_for :template_engine
  
  def add_route
    route <<-ROUTE.strip
resources :oauth_consumers do
    member do
      get :callback
      get :callback2
      match 'client/*endpoint' => 'oauth_consumers#client'
    end
  end
ROUTE
  end
    
end
