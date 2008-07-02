require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class CookiesNote < AbstractNote
      def initialize(controller)
        @cookies = (controller.send(:cookies) || {}).symbolize_keys
      end

      def self.to_sym
        :cookies
      end

      def title
        "Cookies (#{@cookies.length})"
      end

      def legend
        'Cookies'
      end

      def content
        escape(@cookies.inspect)
      end
    end
  end
end