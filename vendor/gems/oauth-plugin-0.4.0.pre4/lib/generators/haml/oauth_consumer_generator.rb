require 'rails/generators/erb/controller/controller_generator'

module Haml
  module Generators
    class OauthConsumerGenerator < Erb::Generators::Base
      source_root File.expand_path('../oauth_consumer_templates', __FILE__)

      argument :name, :type => :string, :default => 'Oauth'

      def copy_view_files
        template 'index.html.haml',              File.join('app/views', class_path, 'oauth_consumers', 'index.html.haml')
        template 'show.html.haml',               File.join('app/views', class_path, 'oauth_consumers', 'show.html.haml')
      end

      protected
      def handler
        :haml
      end
    end
  end
end
