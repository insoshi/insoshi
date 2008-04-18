require File.dirname(__FILE__) + '/helper'
require File.dirname(__FILE__) + '/../lib/object'

class ObjectTest < LessTests


  def test_in
    assert x = [:a, :b, :c]
    assert :a.in?(x)
    assert !:d.in?(x)
  end

  def test_not_in
    assert x = [:a, :b, :c]
    assert !:a.not_in?(x)
    assert :d.not_in?(x)
  end

  def test_if_nil1
    n = nil
    assert_equal nil, n.if_nil
  end
  
  def test_if_nil2
    n = 1
    assert_equal 1, n.if_nil
  end
  
  def test_if_nil3
    n = :yo
    assert_equal :yo, n.if_nil
  end
  
  def test_if_nil4
    n = nil
    assert_equal 'nil', n.if_nil('nil')
  end


  def test_if_method_nil1
    n = nil
    assert_equal nil, n.if_method_nil(:to_s)
  end
  
  def test_if_method_nil2
    n = 1
    assert_raise NoMethodError do
      n.if_method_nil :yo
    end
  end
  
  def test_if_method_nil3
    n = 1
    assert_nothing_raised do
      assert_equal '1', n.if_method_nil( :to_s)
    end
  end
  
  def test_if_method_nil4
    n = 1
    assert_nothing_raised do
      assert_equal '1', n.if_method_nil( :to_s, 'blah')
    end
  end
  
  def test_if_method_nil5
    n = nil
    assert_nothing_raised do
      assert_equal 'blah', n.if_method_nil( :to_s, 'blah')
    end
  end


end