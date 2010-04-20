module ActionView
  module Helpers
    class InstanceTag
      private
      def datetime_selector_with_name(options, html_options)
        options.merge!(:prefix => options[:name].gsub(/\[[^\[]*\]$/,'')) if options[:name]
        datetime_selector_without_name(options, html_options)        
      end
      alias_method_chain :datetime_selector, :name
    end
  end
end
