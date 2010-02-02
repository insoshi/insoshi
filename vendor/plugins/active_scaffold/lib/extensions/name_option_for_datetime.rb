module ActionView
  module Helpers
    class InstanceTag
      private
      # patch in support for options[:name]
      def datetime_selector_with_name(options, html_options)
        datetime = value(object) || default_datetime(options)

        options = options.dup
        options[:field_name]           = @method_name
        options[:include_position]     = true
        options[:prefix]             ||= @object_name
        options[:index]              ||= @auto_index
        options[:datetime_separator] ||= ' &mdash; '
        options[:time_separator]     ||= ' : '
	options.merge!(:prefix => options[:name].gsub(/\[[^\[]*\]$/,'')) if options[:name]

        DateTimeSelector.new(datetime, options.merge(:tag => true), html_options)
      end
      alias_method_chain :datetime_selector, :name
    end
  end
end
