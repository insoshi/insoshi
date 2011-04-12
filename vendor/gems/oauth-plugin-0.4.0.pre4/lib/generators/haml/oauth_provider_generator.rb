require 'rails/generators/erb/controller/controller_generator'

module Haml
  module Generators
    class OauthProviderGenerator < Erb::Generators::Base
      source_root File.expand_path('../oauth_provider_templates', __FILE__)

      argument :name, :type => :string, :default => 'Oauth'

      def copy_view_files
        template '_form.html.haml',              File.join('app/views', class_path, 'oauth_clients', '_form.html.haml')
        template 'new.html.haml',                File.join('app/views', class_path, 'oauth_clients', 'new.html.haml')
        template 'index.html.haml',              File.join('app/views', class_path, 'oauth_clients', 'index.html.haml')
        template 'show.html.haml',               File.join('app/views', class_path, 'oauth_clients', 'show.html.haml')
        template 'edit.html.haml',               File.join('app/views', class_path, 'oauth_clients', 'edit.html.haml')
        template 'authorize.html.haml',          File.join('app/views', class_path, file_name, 'authorize.html.haml')
        template 'oauth2_authorize.html.haml',   File.join('app/views', class_path, file_name, 'oauth2_authorize.html.haml')
        template 'authorize_success.html.haml',  File.join('app/views', class_path, file_name, 'authorize_success.html.haml')
        template 'authorize_failure.html.haml',  File.join('app/views', class_path, file_name, 'authorize_failure.html.haml')
      end

      protected
      def handler
        :haml
      end
    end
  end
end
