module ActiveScaffold
  module SemanticAttributesBridge
    def self.included(base)
      base.class_eval { alias_method_chain :initialize, :semantic_attributes }
    end

    def initialize_with_semantic_attributes(name, active_record_class)
      initialize_without_semantic_attributes(name, active_record_class)
      self.required = !active_record_class.semantic_attributes[self.name].predicates.find {|p| p.allow_empty? == false }.nil?
      active_record_class.semantic_attributes[self.name].predicates.find do |p|
        sem_type = p.class.to_s.split('::')[1].underscore.to_sym
        next if [:required, :association].include?(sem_type)
        @form_ui = sem_type
      end
    end
  end
end
ActiveScaffold::DataStructures::Column.class_eval do
  include ActiveScaffold::SemanticAttributesBridge
end
