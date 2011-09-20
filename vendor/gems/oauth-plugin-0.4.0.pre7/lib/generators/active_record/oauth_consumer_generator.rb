require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class OauthConsumerGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('../oauth_consumer_templates', __FILE__)

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
        class_collisions '', %w(ConsumerToken)
      end

      def copy_models
        template 'consumer_token.rb', File.join('app/models', 'consumer_token.rb')
      end

      def copy_migration
        migration_template 'migration.rb', 'db/migrate/create_oauth_consumer_tokens'
      end
    end
  end
end
