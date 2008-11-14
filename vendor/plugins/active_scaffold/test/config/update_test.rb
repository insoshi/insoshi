require File.join(File.dirname(__FILE__), '../test_helper.rb')

class Config::UpdateTest < Test::Unit::TestCase
  def setup
    @config = ActiveScaffold::Config::Core.new :model_stub
    @update = @config.update
    
    @config._load_action_columns
  end
  
  def test__params_for_columns__returns_all_params
    @config.columns[:a].params.add :keep_a, :a_temp
    
    assert @config.columns[:a].params.include?(:keep_a)
    assert @config.columns[:a].params.include?(:a_temp)
  end
end