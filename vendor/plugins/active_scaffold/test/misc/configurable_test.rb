require File.join(File.dirname(__FILE__), '../test_helper.rb')

class ConfigurableClass
  FOO = 'bar'
  def foo; FOO end
  def self.foo; FOO end
end


class ConfigurableTest < Test::Unit::TestCase
  ##
  ## constants and methods for tests to check against
  ##
  def hello; 'world' end
  HELLO = 'world'

  def test_instance_configuration
    ConfigurableClass.send :include, ActiveScaffold::Configurable

    configurable_class = ConfigurableClass.new

    ##
    ## sanity checks
    ##
    # make sure the configure method is available
    assert ConfigurableClass.respond_to?(:configure)
    # make sure real functions still work
    assert_equal 'bar', configurable_class.foo
    # make sure other functions still don't work
    assert_raise NoMethodError do
      configurable_class.i_do_not_exist
    end

    ##
    ## test normal block behaviors
    ##
    # functions
    assert_equal hello, configurable_class.configure {hello}
    # variables
    assert_equal configurable_class, configurable_class.configure {configurable_class}
    # constants
    assert_equal HELLO, configurable_class.configure {HELLO}

    ##
    ## test extra "localized" block behavior
    ##
    # functions
    assert_equal configurable_class.foo, configurable_class.configure {foo}
    # constants - not working
#    assert_equal configurable_class.FOO, configurable_class.configure {FOO}

  end

  def test_class_configuration
    ConfigurableClass.send :extend, ActiveScaffold::Configurable

    ##
    ## sanity checks
    ##
    # make sure the configure method is available
    assert ConfigurableClass.respond_to?(:configure)
    # make sure real functions still work
    assert_equal 'bar', ConfigurableClass.foo
    # make sure other functions still don't work
    assert_raise NoMethodError do
      ConfigurableClass.i_do_not_exist
    end

    ##
    ## test normal block behaviors
    ##
    # functions
    assert_equal hello, ConfigurableClass.configure {hello}
    # variables
    assert_equal ConfigurableClass, ConfigurableClass.configure {ConfigurableClass}
    # constants
    assert_equal HELLO, ConfigurableClass.configure {HELLO}

    ##
    ## test extra "localized" block behavior
    ##
    # functions
    assert_equal ConfigurableClass.foo, ConfigurableClass.configure {foo}
    # constants - not working
#    assert_equal ConfigurableClass.FOO, ConfigurableClass.configure {FOO}
  end

  def test_arity
    ConfigurableClass.send :extend, ActiveScaffold::Configurable

    # this is the main style
    assert_equal 'foo', ConfigurableClass.configure {'foo'}
    # but we want to let people accept the configurable class as the first argument, too
    assert_equal 'bar', ConfigurableClass.configure {|a| a.foo}
  end
end