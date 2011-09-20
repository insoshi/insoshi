require 'rails/generators/test_unit'

module TestUnit
  module Generators
    class OauthProviderGenerator < Base
      source_root File.expand_path('../templates', __FILE__)

      argument :name, :type => :string, :default => 'Oauth'
      class_option :fixture, :type => :boolean

      def copy_controller_test_files
        template 'clients_controller_test.rb',
                 File.join('test/functional', class_path, "#{file_name}_clients_controller_test.rb")
      end

      def copy_models_test_files
        template 'client_application_test.rb',  File.join('test/unit', 'client_application_test.rb')
        template 'oauth_token_test.rb',         File.join('test/unit', 'oauth_token_test.rb')
        template 'oauth_nonce_test.rb',         File.join('test/unit', 'oauth_nonce_test.rb')
      end

      hook_for :fixture_replacement

      def create_fixture_file
        if options[:fixtures] && options[:fixture_replacement].nil?
          template 'client_applications.yml',   File.join('test/fixtures', 'client_applications.yml')
          template 'oauth_tokens.yml',          File.join('test/fixtures', 'oauth_tokens.yml')
          template 'oauth_nonces.yml',          File.join('test/fixtures', 'oauth_nonces.yml')
        end
      end
    end
  end
end
