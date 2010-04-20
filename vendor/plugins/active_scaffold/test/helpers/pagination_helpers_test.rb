require File.join(File.dirname(__FILE__), '../test_helper.rb')

class PaginationHelpersTest < Test::Unit::TestCase
  include ActiveScaffold::Helpers::PaginationHelpers

  def test_links
    self.stubs(:pagination_ajax_link).returns('l')

    assert_equal '1', links(1, 1)
    assert_equal '1 l', links(1, 2)
    assert_equal '1 l l', links(1, 3)
    assert_equal '1 l l l', links(1, 4)
    assert_equal '1 l l .. l', links(1, 5)
    assert_equal '1 l l .. l', links(1, 6)

    assert_equal 'l 2 l l .. l', links(2, 10)
    assert_equal 'l l 3 l l .. l', links(3, 10)
    assert_equal 'l l l 4 l l .. l', links(4, 10)
    assert_equal 'l .. l l 5 l l .. l', links(5, 10)
    assert_equal 'l .. l l 6 l l .. l', links(6, 10)

    assert_equal '1 l l l l', links(1, 5, 3)
    assert_equal '1 l l l .. l', links(1, 6, 3)
    assert_equal 'l l l l 5 l l l .. l', links(5, 10, 3)
    assert_equal 'l .. l l l 6 l l l l', links(6, 10, 3)
    assert_equal 'l .. l l l 6 l l l .. l', links(6, 20, 3)
  end

  def test_links_with_infinite_pagination
    self.stubs(:pagination_ajax_link).returns('l')

    assert_equal '1 l l .. l .. l', links(1, nil, 2, true)
    assert_equal 'l 2 l l .. l .. l', links(2, nil, 2, true)
    assert_equal 'l l 3 l l .. l .. l', links(3, nil, 2, true)
    assert_equal 'l l l 4 l l .. l .. l', links(4, nil, 2, true)
    assert_equal 'l .. l l 5 l l .. l .. l', links(5, nil, 2, true)

    assert_equal 'l .. l l 20 l l .. l .. l', links(20, nil, 2, true)
    assert_equal 'l .. l l 21 l l .. l .. l', links(21, nil, 2, true)
    assert_equal 'l l .. l l 22 l l .. l .. l', links(22, nil, 2, true)
    assert_equal 'l .. l .. l l 23 l l .. l .. l', links(23, nil, 2, true)

    assert_equal 'l .. l .. l l 100 l l .. l .. l', links(100, nil, 2, true)
    assert_equal 'l .. l .. l l 101 l l .. l .. l', links(101, nil, 2, true)
    assert_equal 'l l .. l .. l l 102 l l .. l .. l', links(102, nil, 2, true)
    assert_equal 'l .. l .. l .. l l 103 l l .. l .. l', links(103, nil, 2, true)
  end

  private
  def links(current, last_page, window_size = 2, infinite = false)
    paginator = stub(:last => last_page = stub(:number => last_page), :infinite? => infinite)
    current_page = stub(:number => current, :pager => paginator)
    pagination_ajax_links(current_page, {}, window_size)
  end
end
