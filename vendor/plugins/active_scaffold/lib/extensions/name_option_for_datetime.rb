module ActionView
  module Helpers
    class InstanceTag
      # patch an issue with integer size parameters
      def to_text_area_tag(options = {})
        options = DEFAULT_TEXT_AREA_OPTIONS.merge(options.stringify_keys)
        add_default_name_and_id(options)

        if size = options.delete("size")
          options["cols"], options["rows"] = size.split("x") if size.class == String
        end

        if method(:value_before_type_cast).arity > 0
          content_tag("textarea", html_escape(options.delete('value') || value_before_type_cast(object)), options)
        else
          content_tag("textarea", html_escape(options.delete('value') || value_before_type_cast), options)
        end
      end

      private

      # patch in support for options[:name]
      def options_with_prefix_with_name(position, options)
        if options[:name]
          options.merge(:prefix => options[:name].dup.insert(-2, "(#{position}i)"))
        else
          options_with_prefix_without_name(position, options)
        end
      end
      alias_method_chain :options_with_prefix, :name
    end
  end
end