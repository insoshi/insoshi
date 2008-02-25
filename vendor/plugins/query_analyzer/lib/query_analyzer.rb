class Array
  protected
    def qa_columnized_row(fields, sized)
      row = []
      fields.each_with_index do |f, i|
        row << sprintf("%0-#{sized[i]}s", f.to_s)
      end
      row.join(' | ')
    end

  public

  def qa_columnized
    sized = {}
    self.each do |row|
      row.values.each_with_index do |value, i|
        sized[i] = [sized[i].to_i, row.keys[i].length, value.to_s.length].max
      end
    end

    table = []
    table << qa_columnized_row(self.first.keys, sized)
    table << '-' * table.first.length
    self.each { |row| table << qa_columnized_row(row.values, sized) }
    table.join("\n   ") # Spaces added to work with format_log_entry
  end
end



module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter < AbstractAdapter
      private
        alias_method :select_without_analyzer, :select
        
        def select(sql, name = nil)
          query_results = select_without_analyzer(sql, name)
          
          if @logger and @logger.level <= Logger::INFO
            @logger.debug(
              @logger.silence do
                format_log_entry("Analyzing #{name}\n",
                  "#{select_without_analyzer("explain #{sql}", name).qa_columnized}\n"
                )
              end
            ) if sql =~ /^select/i
          end          
          query_results
        end
    end
  end
end
