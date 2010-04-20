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
  module CalendarDateSelectBridge
    # Helpers that assist with the rendering of a Form Column
    module FormColumnHelpers
      def active_scaffold_input_calendar_date_select(column, options)
        options[:class] = "#{options[:class]} text-input".strip
        calendar_date_select("record", column.name, options.merge(column.options))
      end      
    end

    module SearchColumnHelpers
      def active_scaffold_search_calendar_date_select(column, options)
        opt_value, from_value, to_value = field_search_params_range_values(column)
        options = column.options.merge(options).except!(:include_blank)
        helper = "select_#{'date' unless options[:discard_date]}#{'time' unless options[:discard_time]}"
        html = []
        html << calendar_date_select("record", column.name, options.merge(:name => "#{options[:name]}[from]", :id => "#{options[:id]}_from", :value => from_value))
        html << calendar_date_select("record", column.name, options.merge(:name => "#{options[:name]}[to]", :id => "#{options[:id]}_to", :value => to_value))
        html * ' - '
      end
    end

    module ViewHelpers
      # Provides stylesheets to include with +stylesheet_link_tag+
      def active_scaffold_stylesheets(frontend = :default)
        super + [calendar_date_select_stylesheets]
      end

      # Provides stylesheets to include with +stylesheet_link_tag+
      def active_scaffold_javascripts(frontend = :default)
        super + [calendar_date_select_javascripts]
      end
    end

    module Finder
      module ClassMethods
        def condition_for_calendar_date_select_type(column, value, like_pattern)
          conversion = column.column.type == :date ? 'to_date' : 'to_time'
          from_value, to_value = ['from', 'to'].collect do |field|
            Time.zone.parse(value[field]) rescue nil
          end

          if from_value.nil? and to_value.nil?
            nil
          elsif !from_value
            ["#{column.search_sql} <= ?", to_value.send(conversion).to_s(:db)]
          elsif !to_value
            ["#{column.search_sql} >= ?", from_value.send(conversion).to_s(:db)]
          else
            ["#{column.search_sql} BETWEEN ? AND ?", from_value.send(conversion).to_s(:db), to_value.send(conversion).to_s(:db)]
          end
        end
      end
    end
  end
end

ActionView::Base.class_eval do
  include ActiveScaffold::CalendarDateSelectBridge::FormColumnHelpers
  include ActiveScaffold::CalendarDateSelectBridge::SearchColumnHelpers
  include ActiveScaffold::CalendarDateSelectBridge::ViewHelpers
end
ActiveScaffold::Finder::ClassMethods.module_eval do
  include ActiveScaffold::CalendarDateSelectBridge::Finder::ClassMethods
end
