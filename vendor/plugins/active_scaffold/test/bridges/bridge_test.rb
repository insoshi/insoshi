def dbg; require "ruby-debug"; debugger; end;

require File.join(File.dirname(__FILE__), '../test_helper.rb')


class Bridges::BridgeTest < Test::Unit::TestCase
  def setup
    @const_store = {}
  end
  
  def teardown
  end
  
  def test__shouldnt_throw_errors
    ActiveScaffold::Bridge.run_all
  end
  
  def test__cds_bridge
    ConstMocker.mock("CalendarDateSelect") do |cm|
      cm.remove
      assert(! bridge_will_be_installed("CalendarDateSelect"))
      cm.declare
      assert(bridge_will_be_installed("CalendarDateSelect"))
    end
  end
  
  def test__file_column_bridge
    ConstMocker.mock("FileColumn") do |cm|
      cm.remove
      assert(! bridge_will_be_installed("FileColumn"))
      cm.declare
      assert(bridge_will_be_installed("FileColumn"))
    end
  end

protected

  def find_bridge(name)
    ActiveScaffold::Bridge.bridges.find{|b| b.name.to_s==name.to_s}
  end
  
  def bridge_will_be_installed(name)
    assert bridge=find_bridge(name), "No bridge found matching #{name}"
    
    bridge.instance_variable_get("@install_if").call
  end
end