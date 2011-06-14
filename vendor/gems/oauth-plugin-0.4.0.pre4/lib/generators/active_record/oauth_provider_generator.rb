require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class OauthProviderGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('../oauth_provider_templates', __FILE__)

      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        next_migration_number = current_migration_number(dirname) + 1
        if ActiveRecord::Base.timestamped_migrations
          [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
        else
          "%.3d" % next_migration_number
        end
      end

      def check_class_collisions
        class_collisions '', %w(ClientApplication OauthNonce RequestToken AccessToken OauthToken)
      end

      def copy_models
        template 'client_application.rb', File.join('app/models', 'client_application.rb')
        template 'oauth_token.rb',        File.join('app/models', 'oauth_token.rb')
        template 'request_token.rb',      File.join('app/models', 'request_token.rb')
        template 'access_token.rb',       File.join('app/models', 'access_token.rb')
        template 'oauth2_token.rb',       File.join('app/models', 'oauth2_token.rb')
        template 'oauth2_verifier.rb',    File.join('app/models', 'oauth2_verifier.rb')
        template 'oauth_nonce.rb',        File.join('app/models', 'oauth_nonce.rb')
      end

      def copy_migration
        migration_template 'migration.rb', 'db/migrate/create_oauth_tables'
      end
    end
  end
end
