require 'test/unit'
require 'rubygems'
require 'action_controller'
require 'action_view/test_case'
require 'mocha'
begin
  require 'redgreen'
rescue LoadError
end

ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.join(File.dirname(__FILE__), 'mock_app')

require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config', 'environment.rb'))

def load_schema
  stdout = $stdout
  $stdout = StringIO.new # suppress output while building the schema
  load File.join(ENV['RAILS_ROOT'], 'db', 'schema.rb')
  $stdout = stdout
end

def silence_stderr(&block)
  stderr = $stderr
  $stderr = StringIO.new
  yield
  $stderr = stderr
end

for file in %w[model_stub const_mocker]
  require File.join(File.dirname(__FILE__), file)
end

class Test::Unit::TestCase
  protected
  def config_for(klass, namespace = nil)
    ActiveScaffold::Config::Core.new("#{namespace}#{klass.to_s.underscore.downcase}")
  end
end
