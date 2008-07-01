require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class ControllerNote < AbstractNote
      def initialize(controller)
        @controller = controller
      end

      def self.to_sym
        :controller
      end

      def row
        :edit
      end

      def title
        'Controller'
      end

      def link
        escape(
          Footnotes::Filter.prefix +
          controller_filename +
          (index_of_method ? "&line=#{controller_line_number + 1}&column=3" : '')
        )
      end

      def valid?
        prefix?
      end

      protected
        # Some controller classes come with the Controller:: module and some don't
        # (anyone know why? -- Duane)
        def controller_filename
          File.join(File.expand_path(RAILS_ROOT), 'app', 'controllers', "#{@controller.class.to_s.underscore}.rb").sub('/controllers/controllers/', '/controllers/')
        end

        def controller_text
          @controller_text ||= IO.read(controller_filename)
        end

        def index_of_method
          (controller_text =~ /def\s+#{@controller.action_name}[\s\(]/)
        end

        def controller_line_number
          lines_from_index(controller_text, index_of_method)
        end

        def lines_from_index(string, index)
          lines = string.to_a
          running_length = 0
          lines.each_with_index do |line, i|
            running_length += line.length
            if running_length > index
              return i
            end
          end
        end
    end
  end
end