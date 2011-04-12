require 'rails/generators/erb'

module Erb
  module Generators
    class OauthConsumerGenerator < Erb::Generators::Base
      source_root File.expand_path('../oauth_consumer_templates', __FILE__)

      def copy_view_files
        template 'index.html.erb',              File.join('app/views', class_path, 'oauth_consumers', 'index.html.erb')
        template 'show.html.erb',               File.join('app/views', class_path, 'oauth_consumers', 'show.html.erb')
      end
    end
  end
end
