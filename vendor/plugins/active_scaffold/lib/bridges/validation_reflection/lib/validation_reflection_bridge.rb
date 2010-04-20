module ActiveScaffold
  module ValidationReflectionBridge
    def self.included(base)
      base.class_eval { alias_method_chain :initialize, :validation_reflection }
    end

    def initialize_with_validation_reflection(name, active_record_class)
      initialize_without_validation_reflection(name, active_record_class)
      column_names = [name]
      column_names << @association.primary_key_name if @association
      self.required = column_names.any? do |column_name|
        active_record_class.reflect_on_validations_for(column_name.to_sym).any? do |val|
          val.macro == :validates_presence_of or (val.macro == :validates_inclusion_of and not val.options[:allow_nil] and not val.options[:allow_blank])
        end
      end
    end
  end
end
ActiveScaffold::DataStructures::Column.class_eval do
  include ActiveScaffold::ValidationReflectionBridge
end
