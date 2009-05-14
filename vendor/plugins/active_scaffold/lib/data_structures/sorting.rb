module ActiveScaffold::DataStructures
  # encapsulates the column sorting configuration for the List view
  class Sorting
    include Enumerable

    def initialize(columns)
      @columns = columns
      @clauses = []
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
  end
end