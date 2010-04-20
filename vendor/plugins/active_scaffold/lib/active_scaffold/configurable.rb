module ActiveScaffold
  # Exposes a +configure+ method that accepts a block and runs all contents of the block in two contexts, as opposed to the normal one. First, everything gets evaluated as part of the object including Configurable. Then, as a failover, missing methods and variables are evaluated in the original binding of the block.
  #
  # Note that this only works with "barewords". Constants, instance variables, and class variables are not currently supported in both contexts.
  #
  # May add the given functionality at both the class and instance level. For the former, use +extend+, and for the latter, use +include+.
  module Configurable
    def configure(&configuration_block)
      return unless configuration_block
      @configuration_binding = configuration_block.binding
      ret = instance_exec self, &configuration_block
      @configuration_binding = nil
      return ret
    end

    # this method will surely need tweaking. for example, i'm not sure if it should call super before or after it tries to eval with the binding.
    def method_missing(name, *args)
      begin
        super
      rescue NoMethodError, NameError
        if @configuration_binding.nil?
          raise $!
        else
          eval("self", @configuration_binding).send(name, *args)
        end
      end
    end
  end
end
