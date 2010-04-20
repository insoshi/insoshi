# wrap the action rendering for ActiveScaffold controllers
module ActionController #:nodoc:
  class Base
    def render_with_active_scaffold(*args, &block)
      if self.class.uses_active_scaffold? and params[:adapter] and @rendering_adapter.nil?
        @rendering_adapter = true # recursion control
        # if we need an adapter, then we render the actual stuff to a string and insert it into the adapter template
        render :partial => params[:adapter][1..-1],
               :locals => {:payload => render_to_string(args.first, &block)},
               :use_full_path => true, :layout => false
        @rendering_adapter = nil # recursion control
      else
        render_without_active_scaffold(*args, &block)
      end
    end
    alias_method_chain :render, :active_scaffold

    # Rails 2.x implementation is post-initialization on :active_scaffold method
  end
end
