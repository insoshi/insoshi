require 'generators/rspec'

module Rspec
  module Generators
    class OauthProviderGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)

      argument :name, :type => :string, :default => 'Oauth'
      class_option :fixture, :type => :boolean

      def copy_controller_spec_files
        template 'clients_controller_spec.rb',
          File.join('spec/controllers', class_path, "#{file_name}_clients_controller_spec.rb")
      end

      def copy_models_spec_files
        template 'client_application_spec.rb',  File.join('spec/models', 'client_application_spec.rb')
        template 'oauth_token_spec.rb',         File.join('spec/models', 'oauth_token_spec.rb')
        template 'oauth2_token_spec.rb',        File.join('spec/models', 'oauth2_token_spec.rb')
        template 'oauth2_verifier_spec.rb',     File.join('spec/models', 'oauth2_verifier_spec.rb')
        template 'oauth_nonce_spec.rb',         File.join('spec/models', 'oauth_nonce_spec.rb')
      end

      hook_for :fixture_replacement

      def create_fixture_file
        if options[:fixtures] && options[:fixture_replacement].nil?
          template 'client_applications.yml', File.join('test/fixtures', 'client_applications.yml')
          template 'oauth_tokens.yml',        File.join('test/fixtures', 'oauth_tokens.yml')
          template 'oauth_nonces.yml',        File.join('test/fixtures', 'oauth_nonces.yml')
        end
      end
    end
  end
end
