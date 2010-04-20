module ActiveScaffold
  module Helpers
    # Helpers that assist with the rendering of a List Column
    module ShowColumnHelpers
      def show_column_value(record, column)
        # check for an override helper
        if show_column_override? column
          # we only pass the record as the argument. we previously also passed the formatted_value,
          # but mike perham pointed out that prohibited the usage of overrides to improve on the
          # performance of our default formatting. see issue #138.
          send(show_column_override(column), record)
        # second, check if the dev has specified a valid list_ui for this column
        elsif column.list_ui and override_show_column_ui?(column.list_ui)
          send(override_show_column_ui(column.list_ui), column, record)
        else
          if column.column and override_show_column_ui?(column.column.type)
            send(override_show_column_ui(column.column.type), column, record)
          else
            get_column_value(record, column)
          end
        end
      end

      def active_scaffold_show_text(column, record)
        simple_format(clean_column_value(record.send(column.name)))
      end

      def show_column_override(column)
        "#{column.name.to_s.gsub('?', '')}_show_column" # parse out any question marks (see issue 227)
      end

      def show_column_override?(column)
        respond_to?(show_column_override(column))
      end

      def override_show_column_ui?(list_ui)
        respond_to?(override_show_column_ui(list_ui))
      end

      # the naming convention for overriding show types with helpers
      def override_show_column_ui(list_ui)
        "active_scaffold_show_#{list_ui}"
      end
    end
  end
end
