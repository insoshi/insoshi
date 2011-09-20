require 'rails/generators/erb'

module Erb
  module Generators
    class OauthProviderGenerator < Erb::Generators::Base
      source_root File.expand_path('../oauth_provider_templates', __FILE__)

      argument :name, :type => :string, :default => 'Oauth'

      def copy_view_files
        template '_form.html.erb',              File.join('app/views', class_path, 'oauth_clients', '_form.html.erb')
        template 'new.html.erb',                File.join('app/views', class_path, 'oauth_clients', 'new.html.erb')
        template 'index.html.erb',              File.join('app/views', class_path, 'oauth_clients', 'index.html.erb')
        template 'show.html.erb',               File.join('app/views', class_path, 'oauth_clients', 'show.html.erb')
        template 'edit.html.erb',               File.join('app/views', class_path, 'oauth_clients', 'edit.html.erb')
        template 'authorize.html.erb',          File.join('app/views', class_path, file_name, 'authorize.html.erb')
        template 'oauth2_authorize.html.erb',   File.join('app/views', class_path, file_name, 'oauth2_authorize.html.erb')
        template 'authorize_success.html.erb',  File.join('app/views', class_path, file_name, 'authorize_success.html.erb')
        template 'authorize_failure.html.erb',  File.join('app/views', class_path, file_name, 'authorize_failure.html.erb')
      end
    end
  end
end
