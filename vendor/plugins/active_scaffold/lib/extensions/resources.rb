module ActionController
  module Resources
    class Resource
      ACTIVE_SCAFFOLD_ROUTING = {
        :collection => {:show_search => :get, :update_table => :get, :edit_associated => :get, :list => :get, :new_existing => :get},
        :member => {:row => :get, :nested => :get, :edit_associated => :get, :add_association => :get, :update_column => :post}
      }

      # by overwriting the attr_reader :options, we can parse out a special :active_scaffold flag just-in-time.
      def options
        if @options.delete :active_scaffold
          logger.info "ActiveScaffold: extending RESTful routes for #{@plural}"
          @options[:collection] ||= {}
          @options[:collection].merge! ACTIVE_SCAFFOLD_ROUTING[:collection]
          @options[:member] ||= {}
          @options[:member].merge! ACTIVE_SCAFFOLD_ROUTING[:member]
        end
        @options
      end

      def logger
        ActionController::Base::logger
      end
    end
  end
end