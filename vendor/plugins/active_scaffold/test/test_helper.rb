require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))

for file in %w[model_stub const_mocker]
  require File.join(File.dirname(__FILE__), file)
end

ModelStub.connection.instance_eval do
  def quote_column_name(name)
    name
  end
end