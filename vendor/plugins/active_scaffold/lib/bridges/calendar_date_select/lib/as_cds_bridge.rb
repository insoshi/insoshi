module ActiveScaffold::Config
  class Core < Base

    def initialize_with_calendar_date_select(model_id)
      initialize_without_calendar_date_select(model_id)
      
      calendar_date_select_fields = self.model.columns.collect{|c| c.name.to_sym if [:date, :datetime].include?(c.type) }.compact
      # check to see if file column was used on the model
      return if calendar_date_select_fields.empty?
      
      # automatically set the forum_ui to a file column
      calendar_date_select_fields.each{|field|
        self.columns[field].form_ui = :calendar_date_select
      }
    end
    
    alias_method_chain :initialize, :calendar_date_select
    
  end
end


module ActiveScaffold
  module Helpers
    # Helpers that assist with the rendering of a Form Column
    module FormColumnHelpers
      def active_scaffold_input_calendar_date_select(column, options)
        options[:class] = "#{options[:class]} text-input".strip
        calendar_date_select("record", column.name, options.merge(column.options))
      end      
    end
  end
end

module ActiveScaffold
  module Helpers
    module ViewHelpers

      # Provides stylesheets to include with +stylesheet_link_tag+
      def active_scaffold_stylesheets_with_calendar_date_select(frontend = :default)
        active_scaffold_stylesheets_without_calendar_date_select.to_a << calendar_date_select_stylesheets
      end
      alias_method_chain :active_scaffold_stylesheets, :calendar_date_select

      # Provides stylesheets to include with +stylesheet_link_tag+
      def active_scaffold_javascripts_with_calendar_date_select(frontend = :default)
        active_scaffold_javascripts_without_calendar_date_select.to_a << calendar_date_select_javascripts
      end
      alias_method_chain :active_scaffold_javascripts, :calendar_date_select
      
    end
  end
end
