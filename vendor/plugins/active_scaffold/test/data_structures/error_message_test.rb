require File.join(File.dirname(__FILE__), '../test_helper.rb')

class ErrorMessageTest < Test::Unit::TestCase
  def setup
    @error = ActiveScaffold::DataStructures::ErrorMessage.new 'foo'
  end

  def test_attributes
    assert @error.public_attributes.has_key?(:error)
    assert_equal 'foo', @error.public_attributes[:error]
  end

  def test_xml
    xml = Hash.from_xml(@error.to_xml)
    assert xml.has_key?('errors')
    assert xml['errors'].has_key?('error')
    assert_equal 'foo', xml['errors']['error']
  end

  def test_yaml
    yml = nil
    assert_nothing_raised do
      yml = YAML.load(@error.to_yaml)
    end
    assert yml.has_key?(:error)
    assert_equal 'foo', yml[:error]
  end
end