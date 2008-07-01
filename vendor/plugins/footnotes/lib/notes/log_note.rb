require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class LogNote < AbstractNote
      def initialize(controller)
        @controller = controller
      end

      def self.to_sym
        :log
      end

      def title
        'Log'
      end

      def legend
        'Log'
      end
      
      def content
        "<pre>#{escape(log_tail)}</pre>"
      end

      protected
        def log_tail
          file_string = File.open(RAILS_DEFAULT_LOGGER.instance_variable_get('@log').path).read.to_s

          # We try to select the specified action from the log
          # If we can't find it, we get the last 100 lines
          #
          if rindex = file_string.rindex('Processing '+@controller.controller_class_name+'#'+@controller.action_name)
            file_string[rindex..-1].gsub(/\e\[.+?m/, '')
          else
            lines = file_string.split("\n")
            index = [lines.size-100,0].max
            lines[index..-1].join("\n")
          end
        end
    end
  end
end