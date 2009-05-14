# Apply patch (http://dev.rubyonrails.org/changeset/6343) that is already in edge, soon to be 1.2.4
# Allow array and hash query parameters. Array route parameters are converted/to/a/path as before.  #6765, #7047, #7462 [bgipsy, Jeremy McAnally, Dan Kubb, brendan]
module ActionController
  module Routing
    class Route
      def build_query_string(hash, only_keys = nil)
        elements = []

        (only_keys || hash.keys).each do |key|
          if value = hash[key]
            elements << value.to_query(key)
          end
        end

        elements.empty? ? '' : "?#{elements.sort * '&'}"
      end
    end

    class DynamicSegment
      def extract_value
        "#{local_name} = hash[:#{key}] && hash[:#{key}].to_param #{"|| #{default.inspect}" if default}"
      end
    end

    class RouteSet #:nodoc:
      def options_as_params(options)
        options_as_params = options.clone
        options_as_params[:action] ||= 'index' if options[:controller]
        options_as_params[:action] = options_as_params[:action].to_s if options_as_params[:action]
        options_as_params[:controller] = options_as_params[:controller].to_s if options_as_params[:controller]
        options_as_params
      end
    end
  end
end

class Object
  def to_query(key) #:nodoc:
    "#{CGI.escape(key.to_s)}=#{CGI.escape(to_param.to_s)}"
  end
end

class Array
  def to_query(key) #:nodoc:
    collect { |value| value.to_query("#{key}[]") } * '&'
  end
end

module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Hash #:nodoc:
      module Conversions
        def to_query(namespace = nil)
          collect do |key, value|
            value.to_query(namespace ? "#{namespace}[#{key}]" : key)
          end.sort * '&'
        end
      end
    end
  end
end
