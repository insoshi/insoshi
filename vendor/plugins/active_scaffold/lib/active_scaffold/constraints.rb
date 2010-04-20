module ActiveScaffold
  module Constraints
    def self.included(base)
      base.module_eval do
        before_filter :register_constraints_with_action_columns
      end
    end

    protected

    # Returns the current constraints
    def active_scaffold_constraints
      return active_scaffold_session_storage[:constraints] || {}
    end

    # For each enabled action, adds the constrained columns to the ActionColumns object (if it exists).
    # This lets the ActionColumns object skip constrained columns.
    #
    # If the constraint value is a Hash, then we assume the constraint is a multi-level association constraint (the reverse of a has_many :through) and we do NOT register the constraint column.
    def register_constraints_with_action_columns
      constrained_fields = active_scaffold_constraints.reject{|k, v| v.is_a? Hash}.keys.collect{|k| k.to_sym}

      if self.class.uses_active_scaffold?
        # we actually want to do this whether constrained_fields exist or not, so that we can reset the array when they don't
        active_scaffold_config.actions.each do |action_name|
          action = active_scaffold_config.send(action_name)
          next unless action.respond_to? :columns
          action.columns.constraint_columns = constrained_fields
        end
      end
    end

    # Returns search conditions based on the current scaffold constraints.
    #
    # Supports constraints based on either a column name (in which case it checks for an association
    # or just uses the search_sql) or a database field name.
    #
    # All of this work is primarily to support nested scaffolds in a manner generally useful for other
    # embedded scaffolds.
    def conditions_from_constraints
      conditions = nil
      active_scaffold_constraints.each do |k, v|
        column = active_scaffold_config.columns[k]
        constraint_condition = if column
          # Assume this is a multi-level association constraint.
          # example:
          #   data model: Park -> Den -> Bear
          #   constraint: :den => {:park => 5}
          if v.is_a? Hash
            far_association = column.association.klass.reflect_on_association(v.keys.first)
            field = far_association.klass.primary_key
            table = far_association.table_name

            active_scaffold_includes.concat([{k => v.keys.first}]) # e.g. {:den => :park}
            constraint_condition_for("#{table}.#{field}", v.values.first)

          # association column constraint
          elsif column.association
            if column.association.macro == :has_and_belongs_to_many
              active_scaffold_habtm_joins.concat column.includes
            else
              active_scaffold_includes.concat column.includes
            end
            condition_from_association_constraint(column.association, v)

          # regular column constraints
          elsif column.searchable?
            active_scaffold_includes.concat column.includes
            constraint_condition_for(column.search_sql, v)
          end
        # unknown-to-activescaffold-but-real-database-column constraint
        elsif active_scaffold_config.model.column_names.include? k.to_s
          constraint_condition_for(k.to_s, v)
        else
          raise ActiveScaffold::MalformedConstraint, constraint_error(active_scaffold_config.model, k), caller
        end

        conditions = merge_conditions(conditions, constraint_condition)
      end

      conditions
    end

    # We do NOT want to use .search_sql. If anything, search_sql will refer
    # to a human-searchable value on the associated record.
    def condition_from_association_constraint(association, value)
      # when the reverse association is a :belongs_to, the id for the associated object only exists as
      # the primary_key on the other table. so for :has_one and :has_many (when the reverse is :belongs_to),
      # we have to use the other model's primary_key.
      #
      # please see the relevant tests for concrete examples.
      field = if [:has_one, :has_many].include?(association.macro)
        association.klass.primary_key
      elsif [:has_and_belongs_to_many].include?(association.macro)
        association.association_foreign_key
      else
        association.options[:foreign_key] || association.name.to_s.foreign_key
      end

      table = case association.macro
        when :has_and_belongs_to_many
        association.options[:join_table]

        when :belongs_to
        active_scaffold_config.model.table_name

        else
        association.table_name
      end

      if association.options[:primary_key]
        value = association.klass.find(value).send(association.options[:primary_key])
      end

      condition = constraint_condition_for("#{table}.#{field}", value)
      if association.options[:polymorphic]
        condition = merge_conditions(
          condition,
          constraint_condition_for("#{table}.#{association.name}_type", params[:parent_model].to_s)
        )
      end

      condition
    end

    def constraint_error(klass, column_name)
      "Malformed constraint `#{klass}##{column_name}'. If it's a legitimate column, and you are using a nested scaffold, please specify or double-check the reverse association name."
    end

    # Applies constraints to the given record.
    #
    # Searches through the known columns for association columns. If the given constraint is an association,
    # it assumes that the constraint value is an id. It then does a association.klass.find with the value
    # and adds the associated object to the record.
    #
    # For some operations ActiveRecord will automatically update the database. That's not always ok.
    # If it *is* ok (e.g. you're in a transaction), then set :allow_autosave to true.
    def apply_constraints_to_record(record, options = {})
      options[:allow_autosave] = false if options[:allow_autosave].nil?

      active_scaffold_constraints.each do |k, v|
        column = active_scaffold_config.columns[k]
        if column and column.association
          if column.plural_association?
            record.send("#{k}").send(:<<, column.association.klass.find(v))
          elsif column.association.options[:polymorphic]
            record.send("#{k}=", params[:parent_model].constantize.find(v))
          else # regular singular association
            record.send("#{k}=", column.association.klass.find(v))

            # setting the belongs_to side of a has_one isn't safe. if the has_one was already
            # specified, rails won't automatically clear out the previous associated record.
            #
            # note that we can't take the extra step to correct this unless we're permitted to
            # run operations where activerecord auto-saves the object.
            reverse = column.association.klass.reflect_on_association(column.association.reverse)
            if reverse.macro == :has_one and options[:allow_autosave]
              record.send(k).send("#{column.association.reverse}=", record)
            end
          end
        else
          record.send("#{k}=", v)
        end
      end
    end

    private

    def constraint_condition_for(sql, value)
      value.nil? ? "#{sql} IS NULL" : ["#{sql} = ?", value]
    end
  end
end
