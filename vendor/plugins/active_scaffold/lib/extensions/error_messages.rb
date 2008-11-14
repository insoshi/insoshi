module ActiveRecord
  class Errors
    # uses config.columns[attr].label instead of attr.humanize, for improved consistency in form feedback.
    # also passes strings through as_(), since it's handy.
    def as_full_messages(config)
      @as_config = config
      full_messages = []

      @errors.each_key do |attr|
        @errors[attr].each do |msg|
          next if msg.nil?

          if attr == "base"
            full_messages << as_(msg)
          else
            label = as_(config.columns[attr].label) if config and config.columns[attr]
            label ||= @base.class.human_attribute_name(attr)
            full_messages << label + " " + as_(msg)
          end
        end
      end
      full_messages
    end
  end
end

module ActionView
  module Helpers
    module ActiveRecordHelper
      # overrides the standard error_messages_for() to use our own as_full_messages()
      # also passes strings through as_(), since it's handy.
      def error_messages_for(*params)
        options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
        objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
        count   = objects.inject(0) {|sum, object| sum + object.errors.count }
        unless count.zero?
          html = {}
          [:id, :class].each do |key|
            if options.include?(key)
              value = options[key]
              html[key] = value unless value.blank?
            else
              html[key] = 'errorExplanation'
            end
          end
          error_message = "error prohibited this"
          header_message = as_("%d #{error_message} %s from being saved", count, (options[:object_name] || params.first).to_s.gsub('_', ' '))
          # Change 'error' to 'errors' for english setups void of a localization plugin
          header_message.gsub!("error", "errors") if header_message.include?(error_message) and count > 1
          error_messages = objects.map {|object| 
            object.errors.as_full_messages(active_scaffold_config).map {|msg| content_tag(:li, msg) } 
          }
          content_tag(:div,
            content_tag(options[:header_tag] || :h2, header_message) <<
              content_tag(:p, as_('There were problems with the following fields:')) <<
              content_tag(:ul, error_messages),
            html
          )
        else
          ''
        end
      end
    end
  end
end
