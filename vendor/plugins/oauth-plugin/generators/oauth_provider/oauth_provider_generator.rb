require File.expand_path(File.dirname(__FILE__) + "/lib/insert_routes.rb")
class OauthProviderGenerator < Rails::Generator::Base
  default_options :skip_migration => false
  attr_reader   :class_path,
                :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name
  alias_method  :controller_file_name,  :controller_singular_name

  def initialize(runtime_args, runtime_options = {})
    super

    @controller_name = args.shift || 'oauth'
    @controller_singular_name = 'oauth'
    @controller_plural_name = 'oauth'
    @controller_file_name = 'oauth'
    @controller_class_name="Oauth"
    @class_path=''
    @controller_class_path=''
  end

  def manifest
    record do |m|
      
      # Check for class naming collisions.
      # Check for class naming collisions.
      m.class_collisions controller_class_path,       "#{controller_class_name}Controller", # Oauth Controller
                                                      "#{controller_class_name}Helper",
                                                      "#{controller_class_name}ClientsController",
                                                      "#{controller_class_name}ClientsHelper"
      m.class_collisions class_path,                  "ClientApplication","OauthNonce","RequestToken","AccessToken","OauthToken"

      # Controller, model, views, and test directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('app/controllers', controller_class_path)
      m.directory File.join('app/views', controller_class_path, controller_file_name)
      m.directory File.join('app/views', controller_class_path, 'oauth_clients')

      m.template 'client_application.rb',File.join('app/models',"client_application.rb")
      m.template 'oauth_token.rb',    File.join('app/models',"oauth_token.rb")
      m.template 'request_token.rb',  File.join('app/models',"request_token.rb")
      m.template 'access_token.rb',   File.join('app/models',"access_token.rb")
      m.template 'oauth_nonce.rb',    File.join('app/models',"oauth_nonce.rb")

      m.template 'controller.rb',File.join('app/controllers',controller_class_path,"#{controller_file_name}_controller.rb")

      m.template 'clients_controller.rb',File.join('app/controllers',controller_class_path,"#{controller_file_name}_clients_controller.rb")
      m.route_name 'oauth', '/oauth',:controller=>'oauth',:action=>'index'
      m.route_name 'authorize', '/oauth/authorize',:controller=>'oauth',:action=>'authorize'
      m.route_name 'request_token', '/oauth/request_token',:controller=>'oauth',:action=>'request_token'
      m.route_name 'access_token', '/oauth/access_token',:controller=>'oauth',:action=>'access_token'
      m.route_name 'test_request', '/oauth/test_request',:controller=>'oauth',:action=>'test_request'

      m.route_resources "#{controller_file_name}_clients".to_sym
      
      if !options[:test_unit]
        m.directory File.join('spec')
        m.directory File.join('spec/models')
        m.directory File.join('spec/fixtures', class_path)
        m.directory File.join('spec/controllers', controller_class_path)
        
        m.template 'client_application_spec.rb',File.join('spec/models',"client_application_spec.rb")
        m.template 'oauth_token_spec.rb',    File.join('spec/models',"oauth_token_spec.rb")
        m.template 'oauth_nonce_spec.rb',    File.join('spec/models',"oauth_nonce_spec.rb")
        m.template 'client_applications.yml',File.join('spec/fixtures',"client_applications.yml")
        m.template 'oauth_tokens.yml',    File.join('spec/fixtures',"oauth_tokens.yml")
        m.template 'oauth_nonces.yml',    File.join('spec/fixtures',"oauth_nonces.yml")
        m.template 'controller_spec_helper.rb', File.join('spec/controllers', controller_class_path,"#{controller_file_name}_controller_spec_helper.rb")
        m.template 'controller_spec.rb',File.join('spec/controllers',controller_class_path,"#{controller_file_name}_controller_spec.rb")      
        m.template 'clients_controller_spec.rb',File.join('spec/controllers',controller_class_path,"#{controller_file_name}_clients_controller_spec.rb")
      else
        m.directory File.join('test')
        m.directory File.join('test/unit')
        m.directory File.join('test/fixtures', class_path)
        m.directory File.join('test/functional', controller_class_path)
        m.template 'client_application_test.rb',File.join('test/unit',"client_application_test.rb")
        m.template 'oauth_token_test.rb',    File.join('test/unit',"oauth_token_test.rb")
        m.template 'oauth_nonce_test.rb',    File.join('test/unit',"oauth_nonce_test.rb")
        m.template 'client_applications.yml',File.join('test/fixtures',"client_applications.yml")
        m.template 'oauth_tokens.yml',    File.join('test/fixtures',"oauth_tokens.yml")
        m.template 'oauth_nonces.yml',    File.join('test/fixtures',"oauth_nonces.yml")
        m.template 'controller_test_helper.rb', File.join('test', controller_class_path,"#{controller_file_name}_controller_test_helper.rb")
        m.template 'controller_test.rb',File.join('test/functional',controller_class_path,"#{controller_file_name}_controller_test.rb")
        m.template 'clients_controller_test.rb',File.join('test/functional',controller_class_path,"#{controller_file_name}_clients_controller_test.rb")
      end
      
      
      @template_extension= options[:haml] ? "haml" : "erb"
      
      m.template "_form.html.#{@template_extension}",  File.join('app/views', controller_class_path, 'oauth_clients', "_form.html.#{@template_extension}")
      m.template "new.html.#{@template_extension}",  File.join('app/views', controller_class_path, 'oauth_clients', "new.html.#{@template_extension}")
      m.template "index.html.#{@template_extension}",  File.join('app/views', controller_class_path, 'oauth_clients', "index.html.#{@template_extension}")
      m.template "show.html.#{@template_extension}",  File.join('app/views', controller_class_path, 'oauth_clients', "show.html.#{@template_extension}")
      m.template "edit.html.#{@template_extension}",  File.join('app/views', controller_class_path, 'oauth_clients', "edit.html.#{@template_extension}")
      m.template "authorize.html.#{@template_extension}",  File.join('app/views', controller_class_path, controller_file_name, "authorize.html.#{@template_extension}")
      m.template "authorize_success.html.#{@template_extension}",  File.join('app/views', controller_class_path, controller_file_name, "authorize_success.html.#{@template_extension}")
      m.template "authorize_failure.html.#{@template_extension}",  File.join('app/views', controller_class_path, controller_file_name, "authorize_failure.html.#{@template_extension}")
      
      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "CreateOauthTables"
        }, :migration_file_name => "create_oauth_tables"
      end
    end
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name}"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration", 
             "Don't generate a migration file") { |v| options[:skip_migration] = v }
      opt.on("--test-unit", 
             "Generate the Test::Unit compatible tests instead of RSpec") { |v| options[:test_unit] = v }
      opt.on("--haml", 
            "Templates use haml") { |v| options[:haml] = v }
    end
end
