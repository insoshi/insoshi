module ActiveScaffold
  module Helpers
    # Helpers that assist with the rendering of a Form Column
    module FormColumns
      def active_scaffold_input_file_column(column, options)
        if @record.send(column.name) 
          # we already have a value?  display the form for deletion.
          content_tag(
            :div, 
            content_tag(
              :div, 
              get_column_value(@record, column) + " " +
              hidden_field(:record, "delete_#{column.name}", :value => "false") +
              " | " +
              link_to_function(as_("Remove file"), "$(this).previous().value='true'; p=$(this).up(); p.hide(); p.next().show();"),
              {}
            ) +
            content_tag(
              :div,
              file_column_field("record", column.name, options),
              :style => "display: none"
            ),
            {}
          )
        else
          # no, just display the file_column_field
          file_column_field("record", column.name, options)
        end
      end      
    end
  end
end