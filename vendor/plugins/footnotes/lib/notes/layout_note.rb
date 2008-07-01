require "#{File.dirname(__FILE__)}/view_note"

module Footnotes
  module Notes
    class LayoutNote < ViewNote
      def self.to_sym
        :layout
      end

      def title
        'Layout'
      end

      def link
        escape(Footnotes::Filter.prefix + layout_file_name)
      end

      def valid?
        @controller.active_layout && prefix?
      end

      protected
        def layout_file_name
          File.expand_path(template_base_path(@controller.active_layout))
        end
    end
  end
end