require File.join(File.dirname(__FILE__), '../test_helper.rb')
#require 'test/model_stub'

class ActiveRecordTest < Test::Unit::TestCase
  def setup
    @record = ModelStub.new
  end

  def test_to_label
    # without anything defined, it'll use the to_s method (e.g. #<ModelStub:0xb7379300>)
    assert_match /^#<[a-z]+:0x[0-9a-f]+>$/i, @record.to_label

    class << @record
      def to_s
        'to_s'
      end
    end

    assert_equal 'to_s', @record.to_label

    class << @record
      def title
        'title'
      end
    end

    assert_equal 'title', @record.to_label

    class << @record
      def label
        'label'
      end
    end

    assert_equal 'label', @record.to_label

    class << @record
      def name
        'name'
      end
    end

    assert_equal 'name', @record.to_label
  end
end