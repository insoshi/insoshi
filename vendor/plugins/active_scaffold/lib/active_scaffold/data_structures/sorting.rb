module ActiveScaffold::DataStructures
  # encapsulates the column sorting configuration for the List view
  class Sorting
    include Enumerable

    def initialize(columns)
      @columns = columns
      @clauses = []
    end
    
    def set_default_sorting(model)
      last_scope = model.default_scoping.last
      if last_scope.nil?  || last_scope[:find].nil? || last_scope[:find][:order].nil?
        set(model.primary_key, 'ASC') if model.column_names.include?(model.primary_key)
      else
        set_sorting_from_order_clause(last_scope[:find][:order].to_s, model.table_name)
        @default_sorting = true
      end
    end
    
    # add a clause to the sorting, assuming the column is sortable
    def add(column_name, direction = nil)
      direction ||= 'ASC'
      direction = direction.to_s.upcase
      column = get_column(column_name)
      raise ArgumentError, "Could not find column #{column_name}" if column.nil?
      raise ArgumentError, "Sorting direction unknown" unless [:ASC, :DESC].include? direction.to_sym
      @clauses << [column, direction] if column.sortable?
      raise ArgumentError, "Can't mix :method- and :sql-based sorting" if mixed_sorting?
    end

    # an alias for +add+. must accept its arguments in a slightly different form, though.
    def <<(arg)
      add(*arg)
    end

    # clears the sorting before setting to the given column/direction
    def set(*args)
      clear
      add(*args)
    end

    # clears the sorting
    def clear
      @default_sorting = false
      @clauses = []
    end

    # checks whether the given column (a Column object or a column name) is in the sorting
    def sorts_on?(column)
      !get_clause(column).nil?
    end

    def direction_of(column)
      clause = get_clause(column)
      return if clause.nil?
      clause[1]
    end

    # checks whether any column is configured to sort by method (using a proc)
    def sorts_by_method?
      @clauses.any? { |sorting| sorting[0].sort.is_a? Hash and sorting[0].sort.has_key? :method }
    end

    def sorts_by_sql?
      @clauses.any? { |sorting| sorting[0].sort.is_a? Hash and sorting[0].sort.has_key? :sql }
    end

    # iterate over the clauses
    def each
      @clauses.each { |clause| yield clause }
    end

    # provides quick access to the first (and sometimes only) clause
    def first
      @clauses.first
    end

    # builds an order-by clause
    def clause
      return nil if sorts_by_method? || default_sorting?

      # unless the sorting is by method, create the sql string
      order = []
      each do |sort_column, sort_direction|
        sql = sort_column.sort[:sql]
        next if sql.nil? or sql.empty?

        order << "#{sql} #{sort_direction}"
      end

      order.join(', ') unless order.empty?
    end

    protected

    # retrieves the sorting clause for the given column
    def get_clause(column)
      column = get_column(column)
      @clauses.find{ |clause| clause[0] == column}
    end

    # possibly converts the given argument into a column object from @columns (if it's not already)
    def get_column(name_or_column)
      # it's a column
      return name_or_column if name_or_column.is_a? ActiveScaffold::DataStructures::Column
      # it's a name
      name_or_column = name_or_column.to_s.split('.').last if name_or_column.to_s.include? '.'
      return @columns[name_or_column]
    end

    def mixed_sorting?
      sorts_by_method? and sorts_by_sql?
    end
    
    def default_sorting?
      @default_sorting
    end

    def set_sorting_from_order_clause(order_clause, model_table_name = nil)
      clear
      order_clause.split(',').each do |criterion|
        unless criterion.blank?
          order_parts = extract_order_parts(criterion)
          add(order_parts[:column_name], order_parts[:direction]) unless different_table?(model_table_name, order_parts[:table_name])
        end
      end
    end
    
    def extract_order_parts(criterion_parts)
      column_name_part, direction_part = criterion_parts.strip.split(' ')
      column_name_parts = column_name_part.split('.')
      order = {:direction => extract_direction(direction_part),
               :column_name => remove_quotes(column_name_parts.last)}
      order[:table_name] = remove_quotes(column_name_parts[-2]) if column_name_parts.length >= 2
      order
    end
    
    def different_table?(model_table_name, order_table_name)
      !order_table_name.nil? && model_table_name != order_table_name
    end
    
    def remove_quotes(sql_name)
      if sql_name.starts_with?('"') || sql_name.starts_with?('`')
        sql_name[1, (sql_name.length - 2)]
      else
        sql_name
      end
    end
    
    def extract_direction(direction_part)
      if direction_part.to_s.upcase == 'DESC'
        'DESC'
      else
        'ASC'
      end
    end
  end
end
