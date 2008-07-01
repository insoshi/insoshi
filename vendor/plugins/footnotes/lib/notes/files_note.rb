require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class FilesNote < AbstractNote
      def initialize(controller)
        @files = scan_text(controller.response.body)
        parse_files!
      end

      def self.to_sym
        :files
      end

      def row
        :edit
      end

      def content
        @files.empty? ? "" : "<ul><li>#{@files.join("</li><li>")}</li></ul>"
      end

      def valid?
        prefix?
      end

      protected
        def scan_text(text)
          []
        end

        def parse_files!
          @files.collect! do |filename|
            if filename =~ %r{^/}
              full_filename = File.join(File.expand_path(RAILS_ROOT), 'public', filename)
              %{<a href="#{Footnotes::Filter.prefix}#{full_filename}">#{filename}</a>}
            else
              %{<a href="#{filename}">#{filename}</a>}
            end
          end
        end
    end
  end
end