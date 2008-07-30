
# NewRelic instrumentation for ActiveRecord
if defined? ActiveRecord

module ActiveRecord
  class Base
    class << self
      [:find, :count].each do |find_method|
        add_method_tracer find_method, 'ActiveRecord/#{self.name}/find'
        add_method_tracer find_method, 'ActiveRecord/find', :push_scope => false
        add_method_tracer find_method, 'ActiveRecord/all', :push_scope => false
      end
      
      # misc
#      [:columns].each do |method|
#        add_method_tracer method, 'ActiveRecord/misc', :push_scope => false
#        add_method_tracer method, 'ActiveRecord/all', :push_scope => false
#        add_method_tracer method, 'ActiveRecord/#{self.name}/misc'
#      end
      
    end
    [:save, :save!].each do |save_method|
      add_method_tracer save_method, 'ActiveRecord/#{self.class.name}/save'
      add_method_tracer save_method, 'ActiveRecord/save', :push_scope => false
      add_method_tracer save_method, 'ActiveRecord/all', :push_scope => false
    end
    
    add_method_tracer :destroy, 'ActiveRecord/#{self.class.name}/destroy'
    add_method_tracer :destroy, 'ActiveRecord/destroy', :push_scope => false
    add_method_tracer :destroy, 'ActiveRecord/all', :push_scope => false
  end
  
  # instrumentation to catch logged SQL statements in sampled transactions
  module ConnectionAdapters
    class AbstractAdapter
      
      @@my_sql_defined = defined? ActiveRecord::ConnectionAdapters::MysqlAdapter
      @@postgres_defined = defined? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
      
      def log_with_newrelic_instrumentation(sql, name, &block)
        # if we aren't in a blamed context, then add one so that we can see that
        # controllers are calling SQL directly
        # we check scope_depth vs 2 since the controller is 1, and the 
        #      
        if NewRelic::Agent.instance.transaction_sampler.scope_depth < 2
          self.class.trace_method_execution "Database/DirectSQL", true, true, true do
            log_with_capture_sql(sql, name, &block)
          end
        else
          log_with_capture_sql(sql, name, &block)
        end
      end
      
      def log_with_capture_sql(sql, name, &block)
        if @@my_sql_defined && self.is_a?(ActiveRecord::ConnectionAdapters::MysqlAdapter)
          config = @config
        elsif @@postgres_defined && self.is_a?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
          config = @config
        else
          config = nil
        end
        
        result = log_without_newrelic_instrumentation(sql, name, &block)
        
        NewRelic::Agent.instance.transaction_sampler.notice_sql(sql, config)
        
        result
      end
      
      # Compare with #alias_method_chain, which is not available in 
      # Rails 1.1:
      alias_method :log_without_newrelic_instrumentation, :log
      alias_method :log, :log_with_newrelic_instrumentation
      protected :log
      
      add_method_tracer :log, 'Database/#{adapter_name}/#{args[1]}', :metric => false
      add_method_tracer :log, 'Database/all', :push_scope => false
      
    end
  end
  
  # instrumentation for associations
  module Associations
    class AssociationCollection
      add_method_tracer :delete, 'ActiveRecord/#{@owner.class.name}/association delete'
    end
    
    def HasAndBelongsToManyAssociation
      add_method_tracer :find, 'ActiveRecord/#{@owner.class.name}/association find'
      add_method_tracer :create_record, 'ActiveRecord/#{@owner.class.name}/association create'
      add_method_tracer :insert_record, 'ActiveRecord/#{@owner.class.name}/association insert'
    end
    
    class HasManyAssociation
      # add_method_tracer :find, 'ActiveRecord/#{@owner.class.name}/association find'
      # add_method_tracer :insert_record, 'ActiveRecord/#{@owner.class.name}/association insert'
      # add_method_tracer :create_record, 'ActiveRecord/#{@owner.class.name}/association create'
    end
  end
  
end

end