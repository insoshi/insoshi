ActiveScaffold.bridge "ValidationReflection" do
  install do
    require File.join(File.dirname(__FILE__), "lib/validation_reflection_bridge.rb")
  end
  install? do
    ActiveRecord::Base.respond_to? :reflect_on_validations_for
  end
end
