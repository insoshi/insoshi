module ActiveScaffold
  # Provides support for param hashes assumed to be model attributes.
  # Support is primarily needed for creating/editing associated records using a nested hash structure.
  #
  # Paradigm Params Hash (should write unit tests on this):
  #   params[:record] = {
  #     # a simple record attribute
  #     'name' => 'John',
  #     # a plural association hash
  #     'roles' => {
  #       # associate with an existing role
  #       '5' => {'id' => 5}
  #       # associate with an existing role and edit it
  #       '6' => {'id' => 6, 'name' => 'designer'}
  #       # create and associate a new role
  #       '124521' => {'name' => 'marketer'}
  #     }
  #     # a singular association hash
  #     'location' => {'id' => 12, 'city' => 'New York'}
  #   }
  #
  # Simpler association structures are also supported, like:
  #   params[:record] = {
  #     # a simple record attribute
  #     'name' => 'John',
  #     # a plural association ... all ids refer to existing records
  #     'roles' => ['5', '6'],
  #     # a singular association ... all ids refer to existing records
  #     'location' => '12'
  # }
  module AttributeParams
    protected
    # Takes attributes (as from params[:record]) and applies them to the parent_record. Also looks for
    # association attributes and attempts to instantiate them as associated objects.
    #
    # This is a secure way to apply params to a record, because it's based on a loop over the columns
    # set. The columns set will not yield unauthorized columns, and it will not yield unregistered columns.
    def update_record_from_params(parent_record, columns, attributes)
      crud_type = parent_record.new_record? ? :create : :update
      return parent_record unless parent_record.authorized_for?(:crud_type => crud_type)

      multi_parameter_attributes = {}
      attributes.each do |k, v|
        next unless k.include? '('
        column_name = k.split('(').first.to_sym
        multi_parameter_attributes[column_name] ||= []
        multi_parameter_attributes[column_name] << [k, v]
      end

      columns.each :for => parent_record, :crud_type => crud_type, :flatten => true do |column|
        # Set any passthrough parameters that may be associated with this column (ie, file column "keep" and "temp" attributes)
        unless column.params.empty?
          column.params.each{|p| parent_record.send("#{p}=", attributes[p]) if attributes.has_key? p}
        end

        if multi_parameter_attributes.has_key? column.name
          parent_record.send(:assign_multiparameter_attributes, multi_parameter_attributes[column.name])
        elsif attributes.has_key? column.name
          value = column_value_from_param_value(parent_record, column, attributes[column.name]) 

          # we avoid assigning a value that already exists because otherwise has_one associations will break (AR bug in has_one_association.rb#replace)
          parent_record.send("#{column.name}=", value) unless parent_record.send(column.name) == value
          
        # plural associations may not actually appear in the params if all of the options have been unselected or cleared away.
        # the "form_ui" check is necessary, becuase without it we have problems
        # with subforms. the UI cuts out deep associations, which means they're not present in the
        # params even though they're in the columns list. the result is that associations were being
        # emptied out way too often.
        elsif column.form_ui and column.plural_association?
          parent_record.send("#{column.name}=", [])
        end
      end

      if parent_record.new_record?
        parent_record.class.reflect_on_all_associations.each do |a|
          next unless [:has_one, :has_many].include?(a.macro) and not a.options[:through]
          next unless association_proxy = parent_record.send(a.name)

          raise ActiveScaffold::ReverseAssociationRequired, "Association #{a.name}: In order to support :has_one and :has_many where the parent record is new and the child record(s) validate the presence of the parent, ActiveScaffold requires the reverse association (the belongs_to)." unless a.reverse

          association_proxy = [association_proxy] if a.macro == :has_one
          association_proxy.each { |record| record.send("#{a.reverse}=", parent_record) }
        end
      end

      parent_record
    end
    
    def manage_nested_record_from_params(parent_record, column, attributes)
      record = find_or_create_for_params(attributes, column, parent_record)
      if record
        record_columns = active_scaffold_config_for(column.association.klass).subform.columns
        update_record_from_params(record, record_columns, attributes)
        record.unsaved = true
      end
      record
    end
    
    def column_value_from_param_value(parent_record, column, value)
      # convert the value, possibly by instantiating associated objects
      if value.is_a?(Hash)
        # this is just for backwards compatibility. we should clean this up in 2.0.
        if column.form_ui == :select
          ids = if column.singular_association?
            value[:id]
          else
            value.values.collect {|hash| hash[:id]}
          end
          (ids and not ids.empty?) ? column.association.klass.find(ids) : nil

        elsif column.singular_association?
          manage_nested_record_from_params(parent_record, column, value)
        elsif column.plural_association?
          value.collect {|key_value_pair| manage_nested_record_from_params(parent_record, column, key_value_pair[1])}.compact
        else
          value
        end
      else
        if column.singular_association?
          # it's a single id
          column.association.klass.find(value) if value and not value.empty?
        elsif column.plural_association?
          # it's an array of ids
          column.association.klass.find(value) if value and not value.empty?
        elsif column.column && column.column.number? && [:i18n_number, :currency].include?(column.options[:format])
          native = '.'
          delimiter = I18n.t('number.format.delimiter')
          separator = I18n.t('number.format.separator')

          unless delimiter == native && !value.include?(separator) && value !~ /\.\d{3}$/
            value.gsub(/[^0-9\-#{I18n.t('number.format.separator')}]/, '').gsub(I18n.t('number.format.separator'), native)
          else
            value
          end
        else
          # convert empty strings into nil. this works better with 'null => true' columns (and validations),
          # and 'null => false' columns should just convert back to an empty string.
          # ... but we can at least check the ConnectionAdapter::Column object to see if nulls are allowed
          value = nil if value.is_a? String and value.empty? and !column.column.nil? and column.column.null
          value
        end
      end
    end

    # Attempts to create or find an instance of klass (which must be an ActiveRecord object) from the
    # request parameters given. If params[:id] exists it will attempt to find an existing object
    # otherwise it will build a new one.
    def find_or_create_for_params(params, parent_column, parent_record)
      current = parent_record.send(parent_column.name)
      klass = parent_column.association.klass
      return nil if parent_column.show_blank_record and attributes_hash_is_empty?(params, klass)

      if params.has_key? :id
        # modifying the current object of a singular association
        if current and current.is_a? ActiveRecord::Base and current.id.to_s == params[:id]
          return current
        # modifying one of the current objects in a plural association
        elsif current and current.respond_to?(:any?) and current.any? {|o| o.id.to_s == params[:id]}
          return current.detect {|o| o.id.to_s == params[:id]}
        # attaching an existing but not-current object
        else
          return klass.find(params[:id])
        end
      else
        if klass.authorized_for?(:crud_type => :create)
          if parent_column.singular_association?
            return parent_record.send("build_#{parent_column.name}")
          else
            return parent_record.send(parent_column.name).build
          end
        end
      end
    end

    # Determines whether the given attributes hash is "empty".
    # This isn't a literal emptiness - it's an attempt to discern whether the user intended it to be empty or not.
    def attributes_hash_is_empty?(hash, klass)
      hash.all? do |key,value|
        # convert any possible multi-parameter attributes like 'created_at(5i)' to simply 'created_at'
        column_name = key.to_s.split('(').first
        column = klass.columns_hash[column_name]

        # booleans and datetimes will always have a value. so we ignore them when checking whether the hash is empty.
        # this could be a bad idea. but the current situation (excess record entry) seems worse.
        next true if column and [:boolean, :datetime, :date, :time].include?(column.type)

        # defaults are pre-filled on the form. we can't use them to determine if the user intends a new row.
        next true if column and value == column.default.to_s

        if value.is_a?(Hash)
          attributes_hash_is_empty?(value, klass)
        else
          value.respond_to?(:empty?) ? value.empty? : false
        end
      end
    end
  end
end
