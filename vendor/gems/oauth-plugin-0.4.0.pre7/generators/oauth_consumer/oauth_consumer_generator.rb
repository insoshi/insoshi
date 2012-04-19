require File.expand_path(File.dirname(__FILE__) + "/../oauth_provider/lib/insert_routes.rb")

class OauthConsumerGenerator < Rails::Generator::Base
  default_options :skip_migration => false

  def manifest
    record do |m|

      # Controller, helper, views, and test directories.
      m.directory File.join('app/models')
      m.directory File.join('app/controllers')
      m.directory File.join('app/helpers')
      m.directory File.join('app/views', 'oauth_consumers')
      m.directory File.join('config/initializers')

      m.template 'oauth_config.rb',File.join('config/initializers', "oauth_consumers.rb")
      m.template 'consumer_token.rb',File.join('app/models',"consumer_token.rb")

      m.template 'controller.rb',File.join('app/controllers',"oauth_consumers_controller.rb")
      m.route_entry "map.resources :oauth_consumers,:member=>{:callback=>:get}"

      @template_extension= options[:haml] ? "haml" : "erb"

      m.template "show.html.#{@template_extension}",  File.join('app/views', 'oauth_consumers', "show.html.#{@template_extension}")
      m.template "index.html.#{@template_extension}",  File.join('app/views', 'oauth_consumers', "index.html.#{@template_extension}")

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "CreateOauthConsumerTokens"
        }, :migration_file_name => "create_oauth_consumer_tokens"
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
#      opt.on("--test-unit",
#             "Generate the Test::Unit compatible tests instead of RSpec") { |v| options[:test_unit] = v }
      opt.on("--haml",
            "Templates use haml") { |v| options[:haml] = v }
    end
end
