module Footnotes
  module Extensions
    module Exception
      def self.included(base)
        base.class_eval do
          alias_method_chain :clean_backtrace, :links
        end
      end

      def add_links_to_backtrace(lines)
        lines.collect do |line|
          expanded = line.gsub '#{RAILS_ROOT}', RAILS_ROOT
          if match = expanded.match(/^(.+):(\d+):in/) or match = expanded.match(/^(.+):(\d+)\s*$/)
            file = File.expand_path(match[1])
            line_number = match[2]
            html = "<a href='#{Footnotes::Filter.prefix}#{file}&line=#{line_number}'>#{line}</a>"
          else
            line
          end
        end
      end

      def clean_backtrace_with_links
        ::Footnotes::Filter.prefix ? add_links_to_backtrace(clean_backtrace_without_links) : clean_backtrace_without_links
      end
    end

    module ActionView
      def line_number_link
        file = File.expand_path(@file_name)
        "<a href='#{Footnotes::Filter.prefix}#{file}&line=#{line_number}'>#{line_number}</a>"
      end
    end

    module ActionController
      def self.included(base)
        base.class_eval do
          alias_method_chain :template_path_for_local_rescue, :links
        end
      end

      def template_path_for_local_rescue_with_links(exception)
        if ::ActionView::TemplateError === exception && ::Footnotes::Filter.prefix
          File.dirname(__FILE__) + '/../templates/rescues/template_error.erb'
        else
          template_path_for_local_rescue_without_links(exception)
        end
      end
    end
  end
end

Exception.send :include, Footnotes::Extensions::Exception
ActionView::TemplateError.send :include, Footnotes::Extensions::ActionView
ActionController::Base.send :include, Footnotes::Extensions::ActionController