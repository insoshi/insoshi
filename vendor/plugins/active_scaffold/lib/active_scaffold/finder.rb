module ActiveScaffold
  module Finder
    module ClassMethods
      # Takes a collection of search terms (the tokens) and creates SQL that
      # searches all specified ActiveScaffold columns. A row will match if each
      # token is found in at least one of the columns.
      def create_conditions_for_columns(tokens, columns, text_search = :full)
        # if there aren't any columns, then just return a nil condition
        return unless columns.length > 0
        like_pattern = like_pattern(text_search)

        tokens = [tokens] if tokens.is_a? String

        where_clauses = []
        columns.each do |column|
          where_clauses << ((column.column.nil? || column.column.text?) ? "LOWER(#{column.search_sql}) LIKE ?" : "#{column.search_sql} = ?")
        end
        phrase = "(#{where_clauses.join(' OR ')})"

        sql = ([phrase] * tokens.length).join(' AND ')
        tokens = tokens.collect do |value|
          columns.collect {|column| (column.column.nil? || column.column.text?) ? like_pattern.sub('?', value.downcase) : column.column.type_cast(value)}
        end.flatten

        [sql, *tokens]
      end

      # Generates an SQL condition for the given ActiveScaffold column based on
      # that column's database type (or form_ui ... for virtual columns?).
      # TODO: this should reside on the column, not the controller
      def condition_for_column(column, value, text_search = :full)
        like_pattern = like_pattern(text_search)
        return unless column and column.search_sql and not value.blank?
        search_ui = column.search_ui || column.column.type
        begin
          if self.respond_to?("condition_for_#{column.name}_column")
            self.send("condition_for_#{column.name}_column", column, value, like_pattern)
          elsif self.respond_to?("condition_for_#{search_ui}_type")
            self.send("condition_for_#{search_ui}_type", column, value, like_pattern)
          else
            case search_ui
              when :boolean, :checkbox
              ["#{column.search_sql} = ?", column.column.type_cast(value)]
              when :select, :multi_select, :country, :usa_state
              ["#{column.search_sql} in (?)", value]
              else
                if column.column.nil? || column.column.text?
                  ["LOWER(#{column.search_sql}) LIKE ?", like_pattern.sub('?', value.downcase)]
                else
                  ["#{column.search_sql} = ?", column.column.type_cast(value)]
                end
            end
          end
        rescue Exception => e
          logger.error Time.now.to_s + "#{e.inspect} -- on the ActiveScaffold column :#{column.name}, search_ui = #{search_ui} in #{@controller.class}"
          raise e
        end
      end

      def condition_for_integer_type(column, value, like_pattern = nil)
        if !value.is_a?(Hash)
          ["#{column.search_sql} = ?", column.column.nil? ? value.to_f : column.column.type_cast(value)]
        elsif value[:from].blank? or not ActiveScaffold::Finder::NumericComparators.include?(value[:opt])
          nil
        elsif value[:opt] == 'BETWEEN'
          condition = "#{column.search_sql} BETWEEN ? AND ?"
          if column.column.nil?
            [condition, value[:from].to_f, value[:to].to_f]
          else
            [condition, column.column.type_cast(value[:from]), column.column.type_cast(value[:to])]
          end
        else
          ["#{column.search_sql} #{value[:opt]} ?", column.column.nil? ? value[:from].to_f : column.column.type_cast(value[:from])]
        end
      end
      alias_method :condition_for_decimal_type, :condition_for_integer_type
      alias_method :condition_for_float_type, :condition_for_integer_type

      def condition_for_range_type(column, value, like_pattern = nil)
        if !value.is_a?(Hash)
          if column.column.nil? || column.column.text?
            ["LOWER(#{column.search_sql}) LIKE ?", like_pattern.sub('?', value.downcase)]
          else
            ["#{column.search_sql} = ?", column.column.type_cast(value)]
          end
        elsif value[:from].blank?
          nil
        elsif ActiveScaffold::Finder::StringComparators.values.include?(value[:opt])
          ["#{column.search_sql} LIKE ?", value[:opt].sub('?', value[:from])]
        elsif value[:opt] == 'BETWEEN'
          ["#{column.search_sql} BETWEEN ? AND ?", value[:from], value[:to]]
        elsif ActiveScaffold::Finder::NumericComparators.include?(value[:opt])
          ["#{column.search_sql} #{value[:opt]} ?", value[:from]]
        else
          nil
        end
      end
      alias_method :condition_for_string_type, :condition_for_range_type

      def condition_for_datetime_type(column, value, like_pattern = nil)
        conversion = value[:from][:hour].blank? && value[:to][:hour].blank? ? :to_date : :to_time
        from_value, to_value = [:from, :to].collect do |field|
          Time.zone.local(*[:year, :month, :day, :hour, :minute, :second].collect {|part| value[field][part].to_i}) rescue nil
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
      alias_method :condition_for_date_type, :condition_for_datetime_type
      alias_method :condition_for_time_type, :condition_for_datetime_type
      alias_method :condition_for_timestamp_type, :condition_for_datetime_type

      def condition_for_record_select_type(column, value, like_pattern = nil)
        if value.is_a?(Array)
          ["#{column.search_sql} IN (?)", value]
        else
          ["#{column.search_sql} = ?", value]
        end
      end

      def like_pattern(text_search)
        case text_search
          when :full then '%?%'
          when :start then '?%'
          when :end then '%?'
          else '?'
        end
      end
    end

    NumericComparators = [
      '=',
      '>=',
      '<=',
      '>',
      '<',
      '!=',
      'BETWEEN'
    ]
    StringComparators = {
      :contains    => '%?%',
      :begins_with => '?%',
      :ends_with   => '%?'
    }

    def self.included(klass)
      klass.extend ClassMethods
    end

    protected

    attr_writer :active_scaffold_conditions
    def active_scaffold_conditions
      @active_scaffold_conditions ||= []
    end

    attr_writer :active_scaffold_includes
    def active_scaffold_includes
      @active_scaffold_includes ||= []
    end

    attr_writer :active_scaffold_habtm_joins
    def active_scaffold_habtm_joins
      @active_scaffold_habtm_joins ||= []
    end
    
    def all_conditions
      merge_conditions(
        active_scaffold_conditions,                   # from the search modules
        conditions_for_collection,                    # from the dev
        conditions_from_params,                       # from the parameters (e.g. /users/list?first_name=Fred)
        conditions_from_constraints,                  # from any constraints (embedded scaffolds)
        active_scaffold_session_storage[:conditions] # embedding conditions (weaker constraints)
      )
    end
    
    # returns a single record (the given id) but only if it's allowed for the specified action.
    # accomplishes this by checking model.#{action}_authorized?
    # TODO: this should reside on the model, not the controller
    def find_if_allowed(id, crud_type, klass = beginning_of_chain)
      record = klass.find(id)
      raise ActiveScaffold::RecordNotAllowed, "#{klass} with id = #{id}" unless record.authorized_for?(:crud_type => crud_type.to_sym)
      return record
    end

    # returns a Paginator::Page (not from ActiveRecord::Paginator) for the given parameters
    # options may include:
    # * :sorting - a Sorting DataStructure (basically an array of hashes of field => direction, e.g. [{:field1 => 'asc'}, {:field2 => 'desc'}]). please note that multi-column sorting has some limitations: if any column in a multi-field sort uses method-based sorting, it will be ignored. method sorting only works for single-column sorting.
    # * :per_page
    # * :page
    # TODO: this should reside on the model, not the controller
    def find_page(options = {})
      options.assert_valid_keys :sorting, :per_page, :page, :count_includes, :pagination

      search_conditions = all_conditions
      full_includes = (active_scaffold_includes.blank? ? nil : active_scaffold_includes)
      options[:per_page] ||= 999999999
      options[:page] ||= 1
      options[:count_includes] ||= full_includes unless search_conditions.nil?

      klass = beginning_of_chain
      
      # create a general-use options array that's compatible with Rails finders
      finder_options = { :order => options[:sorting].try(:clause),
                         :conditions => search_conditions,
                         :joins => joins_for_finder,
                         :include => options[:count_includes]}
                         
      finder_options.merge! custom_finder_options

      # NOTE: we must use :include in the count query, because some conditions may reference other tables
      count = klass.count(finder_options.reject{|k,v| [:select, :order].include? k}) unless options[:pagination] == :infinite

      # Converts count to an integer if ActiveRecord returned an OrderedHash
      # that happens when finder_options contains a :group key
      count = count.length if count.is_a? ActiveSupport::OrderedHash

      finder_options.merge! :include => full_includes

      # we build the paginator differently for method- and sql-based sorting
      if options[:sorting] and options[:sorting].sorts_by_method?
        pager = ::Paginator.new(count, options[:per_page]) do |offset, per_page|
          sorted_collection = sort_collection_by_column(klass.all(finder_options), *options[:sorting].first)
          sorted_collection.slice(offset, per_page) if options[:pagination]
        end
      else
        pager = ::Paginator.new(count, options[:per_page]) do |offset, per_page|
          finder_options.merge!(:offset => offset, :limit => per_page) if options[:pagination]
          klass.all(finder_options)
        end
      end

      pager.page(options[:page])
    end

    def joins_for_finder
      case joins_for_collection
        when String
          [ joins_for_collection ]
        when Array
          joins_for_collection
        else
          []
      end + active_scaffold_habtm_joins
    end
    
    def merge_conditions(*conditions)
      active_scaffold_config.model.merge_conditions(*conditions)
    end

    # TODO: this should reside on the column, not the controller
    def sort_collection_by_column(collection, column, order)
      sorter = column.sort[:method]
      collection = collection.sort_by { |record|
        value = (sorter.is_a? Proc) ? record.instance_eval(&sorter) : record.instance_eval(sorter)
        value = '' if value.nil?
        value
      }
      collection.reverse! if order.downcase == 'desc'
      collection
    end
  end
end
