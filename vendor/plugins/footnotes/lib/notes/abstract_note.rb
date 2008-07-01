module Footnotes
  module Notes
    # This is the abstrac class for notes.
    #
    class AbstractNote

      class << self
        # Returns the symbol that represents this note.
        #
        def to_sym
          :abstract
        end

        # Return if Note is included in notes array.
        #
        def included?
          Footnotes::Filter.notes.include?(self.to_sym)
        end

        # Action to be called to start the Note.
        # This is applied as a before_filter.
        #
        def start!
        end

        # Action to be called after the Note was used.
        # This is applied as an after_filter.
        #
        def close!
        end
      end

      # Initialize notes.
      # Always receives a controller.
      #
      def initialize(controller = nil)
      end

      # Returns the symbol that represents this note.
      #
      def to_sym
        self.class.to_sym
      end

      # Specifies in which row should appear the title.
      # The default is show.
      #
      def row
        :show
      end

      # If not nil, append the value returned in the specified row.
      #
      def title
      end

      # If not nil, create a fieldset with the value returned as legend.
      #
      def legend
      end

      # When title is specified, this will be the content of the fieldset.
      #
      def content
      end

      # Set href field for Footnotes links.
      # If it's nil, Footnotes will use '#'.
      # 
      def link
      end

      # Set onclick field for Footnotes links.
      # If it's nil, Footnotes will make it open the fieldset.
      # 
      def onclick
      end

      # Insert here any additional stylesheet.
      # This is directly inserted into a <style> tag.
      #
      def stylesheet
      end

      # Insert here any additional javascript.
      # This is directly inserted into a <script> tag.
      #
      def javascript
      end

      # Specifies when should create a note for it.
      # By default, if title exists, it's valid.
      #
      def valid?
        self.title
      end

      # Specifies when should create a fieldset for it, considering it's valid.
      #
      def fieldset?
        self.legend
      end

      # Return if this note is incuded in Footnotes::Filter.notes.
      #
      def included?
        self.class.included?
      end

      # Some helpers to generate notes.
      #
      protected
        # Return if Footnotes::Filter.prefix exists or not.
        # Some notes only work with prefix set.
        #
        def prefix?
          Footnotes::Filter.prefix
        end

        # Escape HTML special characters.
        #
        def escape(text)
          text.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
        end

        # Gets a bidimensional array and create a table.
        # The first array is used as label.
        #
        def mount_table(array, options = {})
          header = array.shift
          return '' if array.empty?

          header = header.collect{|i| escape(i.to_s.humanize) }
          rows = array.collect{|i| "<tr><td>#{i.join('</td><td>')}</td></tr>" }

          <<-TABLE
          <table #{hash_to_xml_attributes(options)}>
            <thead><tr><th>#{header.join('</th><th>')}</th></tr></thead>
            <tbody>#{rows.join}</tbody>
          </table>
          TABLE
        end

        def hash_to_xml_attributes(hash)
          return hash.collect{ |key, value| "#{key.to_s}=\"#{value.gsub('"','\"')}\"" }.join(' ')
        end
    end
  end
end