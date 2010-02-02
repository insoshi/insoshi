module ActionController #:nodoc:
  module Components
    module InstanceMethods
      # Extracts the action_name from the request parameters and performs that action.
      private
        # This is to fix a bug in Rails. 1.2.2 was calling klass.controller_name instead of klass.controller_path, which was in turn setting the params[:controller] => "contacts", instead of params[:controller] => "two/contact". Submitted ticket #7545
        # Namespaces only supported in ActiveScaffold with Rails 1.2.2
        def component_response(options, reuse_response)
          klass    = component_class(options)
          request  = request_for_component(klass.controller_path, options)
          new_response = reuse_response ? response : response.dup

          klass.process_with_components(request, new_response, self)
        end
    end
  end
end