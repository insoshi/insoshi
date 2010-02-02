module ActiveScaffold
  module Helpers
    # A bunch of helper methods to produce the common view ids
    module IdHelpers
      def controller_id
        @controller_id ||= 'as_' + (params[:eid] || params[:parent_controller] || params[:controller]).gsub("/", "__")
      end

      def active_scaffold_id
        "#{controller_id}-active-scaffold"
      end

      def active_scaffold_content_id
        "#{controller_id}-content"
      end

      def active_scaffold_tbody_id
        "#{controller_id}-tbody"
      end

      def active_scaffold_messages_id
        "#{controller_id}-messages"
      end

      def active_scaffold_calculations_id
        "#{controller_id}-calculations"
      end

      def empty_message_id
        "#{controller_id}-empty-message"
      end

      def before_header_id
        "#{controller_id}-search-container"
      end

      def search_form_id
        "#{controller_id}-search-form"
      end

      def search_input_id
        "#{controller_id}-search-input"
      end

      def table_action_id(name)
        "#{controller_id}-action-table-#{name}"
      end

      def action_link_id(link_action,link_id)
        "#{controller_id}-#{link_action}-#{link_id}-link"
      end

      def active_scaffold_column_header_id(column)
        name = column.respond_to?(:name) ? column.name : column.to_s
        clean_id "#{controller_id}-#{name}-column"
      end

      def element_row_id(options = {})
        options[:action] ||= params[:action]
        options[:id] ||= params[:id]
        options[:id] ||= params[:parent_id]
        clean_id "#{controller_id}-#{options[:action]}-#{options[:id]}-row"
      end

      def element_cell_id(options = {})
        options[:action] ||= params[:action]
        options[:id] ||= params[:id]
        options[:id] ||= params[:parent_id]
        options[:name] ||= params[:name]
        clean_id "#{controller_id}-#{options[:action]}-#{options[:id]}-#{options[:name]}-cell"
      end

      def element_form_id(options = {})
        options[:action] ||= params[:action]
        options[:id] ||= params[:id]
        options[:id] ||= params[:parent_id]
        clean_id "#{controller_id}-#{options[:action]}-#{options[:id]}-form"
      end

      def association_subform_id(column)
        klass = column.association.klass.to_s.underscore
        clean_id "#{controller_id}-associated-#{klass}"
      end

      def loading_indicator_id(options = {})
        options[:action] ||= params[:action]
        unless options[:id]
          clean_id "#{controller_id}-#{options[:action]}-loading-indicator"
        else
          clean_id "#{controller_id}-#{options[:action]}-#{options[:id]}-loading-indicator"
        end
      end

      def sub_form_id(options = {})
        options[:id] ||= params[:id]
        options[:id] ||= params[:parent_id]
        clean_id "#{controller_id}-#{options[:id]}-#{options[:association]}-subform"
      end

      def sub_form_list_id(options = {})
        options[:id] ||= params[:id]
        options[:id] ||= params[:parent_id]
        clean_id "#{controller_id}-#{options[:id]}-#{options[:association]}-subform-list"
      end

      def element_messages_id(options = {})
        options[:action] ||= params[:action]
        options[:id] ||= params[:id]
        options[:id] ||= params[:parent_id]
        clean_id "#{controller_id}-#{options[:action]}-#{options[:id]}-messages"
      end

      def action_iframe_id(options)
        "#{controller_id}-#{options[:action]}-#{options[:id]}-iframe"
      end

      private

      # whitelists id-safe characters
      def clean_id(val)
        val.gsub /[^-_0-9a-zA-Z]/, '-'
      end
    end
  end
end
