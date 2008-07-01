require "#{File.dirname(__FILE__)}/files_note"

module Footnotes
  module Notes
    class StylesheetsNote < FilesNote
      def self.to_sym
        :stylesheets
      end

      def title
        "Stylesheets (#{@files.length})"
      end

      def legend
        'Stylesheets'
      end

      protected
        def scan_text(text)
          text.scan(/<link[^>]+href\s*=\s*['"]([^>?'"]+\.css)/im).flatten
        end
    end
  end
end