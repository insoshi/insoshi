module RailsAdmin
  module Adapters
    module ActiveRecord
      def default_scope=(scope)
        @default_scope = scope
      end
    end
  end
  module Config
    module Sections
      class List < RailsAdmin::Config::Sections::Base
        def scope(&block)
          @abstract_model.default_scope = Proc.new
          @abstract_model.instance_eval do
            def scoped
              model.scoped.instance_exec(&@default_scope)
            end
          end
        end
      end
    end
  end
end
