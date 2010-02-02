module ActiveScaffold
  module Helpers
    module ControllerHelpers
      def self.included(controller)
        controller.class_eval { helper_method :params_for }
      end
      
      include ActiveScaffold::Helpers::IdHelpers
      
      def params_for(options = {})
        # :adapter and :position are one-use rendering arguments. they should not propagate.
        # :sort, :sort_direction, and :page are arguments that stored in the session. they need not propagate.
        # and wow. no we don't want to propagate :record.
        # :commit is a special rails variable for form buttons
        blacklist = [:adapter, :position, :sort, :sort_direction, :page, :record, :commit, :_method]
        unless @params_for
          @params_for = params.clone.delete_if { |key, value| blacklist.include? key.to_sym if key }
          @params_for[:controller] = '/' + @params_for[:controller] unless @params_for[:controller].first(1) == '/' # for namespaced controllers
          @params_for.delete(:id) if @params_for[:id].nil?
        end
        @params_for.merge(options)
      end
    end
  end
end
