require 'test/unit'

MARKABY_ROOT = File.join(File.dirname(__FILE__), '..', '..')

require File.join(MARKABY_ROOT,
    '..', # plugins/
    '..', # vendor/
    '..', # RAILS_ROOT
    'config',
    'boot'
  )

Rails::Initializer.run

require 'action_controller/test_process'

Dependencies.load_paths.unshift File.dirname(__FILE__)

$:.unshift MARKABY_ROOT

require 'init'

require 'markaby/kernel_method'


class Monkey < Struct.new(:name)
  def self.find(*args)
    @@monkeys ||= ['Frank', 'Benny', 'Paul'].map { |name| Monkey.new name }
  end
end
