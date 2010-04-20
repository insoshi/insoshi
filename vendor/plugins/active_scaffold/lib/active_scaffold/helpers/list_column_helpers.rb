module ActiveScaffold
  module Helpers
    # Helpers that assist with the rendering of a List Column
    module ListColumnHelpers
      def get_column_value(record, column)
        # check for an override helper
        value = if column_override? column
          # we only pass the record as the argument. we previously also passed the formatted_value,
          # but mike perham pointed out that prohibited the usage of overrides to improve on the
          # performance of our default formatting. see issue #138.
          send(column_override(column), record)
        # second, check if the dev has specified a valid list_ui for this column
        elsif column.list_ui and override_column_ui?(column.list_ui)
          send(override_column_ui(column.list_ui), column, record)

        elsif column.inplace_edit and record.authorized_for?(:action => :update, :column => column.name)
          active_scaffold_inplace_edit(record, column)
        elsif column.column and override_column_ui?(column.column.type)
          send(override_column_ui(column.column.type), column, record)
        else
          value = record.send(column.name)

          if column.association.nil? or column_empty?(value)
            formatted_value = clean_column_value(format_value(value, column.options))
          else
            case column.association.macro
              when :has_one, :belongs_to
                formatted_value = clean_column_value(format_value(value.to_label))

              when :has_many, :has_and_belongs_to_many
                if column.associated_limit.nil?
                  firsts = value.collect { |v| v.to_label }
                else
                  firsts = value.first(column.associated_limit + 1).collect { |v| v.to_label }
                  firsts[column.associated_limit] = '…' if firsts.length > column.associated_limit
                end
                formatted_value = clean_column_value(format_value(firsts.join(', ')))
                formatted_value << " (#{value.length})" if column.associated_number? and column.associated_limit and firsts.length > column.associated_limit
                formatted_value
            end
          end

          formatted_value
        end

        value = '&nbsp;' if value.nil? or (value.respond_to?(:empty?) and value.empty?) # fix for IE 6
        return value
      end

      # TODO: move empty_field_text and &nbsp; logic in here?
      # TODO: move active_scaffold_inplace_edit in here?
      # TODO: we need to distinguish between the automatic links *we* create and the ones that the dev specified. some logic may not apply if the dev specified the link.
      def render_list_column(text, column, record)
        if column.link
          link = column.link
          if column.singular_association? and column_empty?(text)
            column_model = column.association.klass
            controller_actions = active_scaffold_config_for(column_model).actions
            if controller_actions.include?(:create) and column.actions_for_association_links.include? :new and column_model.authorized_for?(:action => :create)
              link = link.clone
              link.action = 'new'
              link.crud_type = :create
              text = as_(:create_new)
              authorized = true
            else
              authorized = false
            end
          else
            associated = record.send(column.association.name)
            authorized = associated.authorized_for?(:action => link.crud_type)
          end
          return "<a class='disabled'>#{text}</a>" unless authorized

          url_options = params_for(:action => nil, :id => record.id, :link => text)
          if column.singular_association? and link.action != 'nested'
            if associated
              url_options[:id] = associated.id
            elsif link.action == 'new'
              url_options.delete :id
              url_options[:parent_id] = record.id
              url_options[:parent_column] = column.association.reverse
              url_options[:parent_model] = record.class.name # needed for polymorphic associations
            end
          end

          render_action_link(link, url_options)
        else
          text
        end
      end

      # There are two basic ways to clean a column's value: h() and sanitize(). The latter is useful
      # when the column contains *valid* html data, and you want to just disable any scripting. People
      # can always use field overrides to clean data one way or the other, but having this override
      # lets people decide which way it should happen by default.
      #
      # Why is it not a configuration option? Because it seems like a somewhat rare request. But it
      # could eventually be an option in config.list (and config.show, I guess).
      def clean_column_value(v)
        h(v)
      end

      ##
      ## Overrides
      ##
      def active_scaffold_column_text(column, record)
        truncate(clean_column_value(record.send(column.name)), :length => 50)
      end

      def active_scaffold_column_checkbox(column, record)
        column_value = record.send(column.name)
        checked = column_value.class.to_s.include?('Class') ? column_value : column_value == 1
        if column.inplace_edit and record.authorized_for?(:action => :update, :column => column.name)
          id_options = {:id => record.id.to_s, :action => 'update_column', :name => column.name.to_s}
          tag_options = {:tag => "span", :id => element_cell_id(id_options), :class => "in_place_editor_field"}
          script = remote_function(:method => 'POST', :url => {:controller => params_for[:controller], :action => "update_column", :column => column.name, :id => record.id.to_s, :value => !column_value, :eid => params[:eid]})
          content_tag(:span, check_box_tag(tag_options[:id], 1, checked, {:onclick => script}) , tag_options)
        else
          check_box_tag(nil, 1, checked, :disabled => true)
        end
      end

      def column_override(column)
        "#{column.name.to_s.gsub('?', '')}_column" # parse out any question marks (see issue 227)
      end

      def column_override?(column)
        respond_to?(column_override(column))
      end

      def override_column_ui?(list_ui)
        respond_to?(override_column_ui(list_ui))
      end

      # the naming convention for overriding column types with helpers
      def override_column_ui(list_ui)
        "active_scaffold_column_#{list_ui}"
      end

      ##
      ## Formatting
      ##

      def format_value(column_value, options = {})
        if column_empty?(column_value)
          active_scaffold_config.list.empty_field_text
        elsif column_value.is_a?(Time) || column_value.is_a?(Date)
          l(column_value, :format => options[:format] || :default)
        else
          column_value.to_s
        end
      end

      # ==========
      # = Inline Edit =
      # ==========
      def format_inplace_edit_column(record,column)
        value = record.send(column.name)
        if column.list_ui == :checkbox
          active_scaffold_column_checkbox(column, record)
        else
          clean_column_value(format_value(value))
        end
      end
      
      def active_scaffold_inplace_edit(record, column)
        formatted_column = format_inplace_edit_column(record,column)
        id_options = {:id => record.id.to_s, :action => 'update_column', :name => column.name.to_s}
        tag_options = {:tag => "span", :id => element_cell_id(id_options), :class => "in_place_editor_field"}
        in_place_editor_options = {:url => {:controller => params_for[:controller], :action => "update_column", :column => column.name, :id => record.id.to_s},
         :with => params[:eid] ? "Form.serialize(form) + '&eid=#{params[:eid]}'" : nil,
         :click_to_edit_text => as_(:click_to_edit),
         :cancel_text => as_(:cancel),
         :loading_text => as_(:loading),
         :save_text => as_(:update),
         :saving_text => as_(:saving),
         :options => "{method: 'post'}",
         :script => true}.merge(column.options)
        content_tag(:span, formatted_column, tag_options) + in_place_editor(tag_options[:id], in_place_editor_options)
      end

    end
  end
end
