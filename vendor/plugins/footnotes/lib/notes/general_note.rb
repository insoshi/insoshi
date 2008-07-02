require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class GeneralNote < AbstractNote
      def self.to_sym
        :general
      end

      def title
        'General Debug'
      end

      def legend
        'General (id="general_debug_info")'
      end

      def content
        'You can use this tab to debug other parts of your application, for example Javascript.'
      end
    end
  end
end