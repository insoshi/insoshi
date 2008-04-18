require File.dirname(__FILE__) + '/helper'
require File.join(File.dirname(__FILE__), '../../../../config/environment')

class StringTest < LessTests
  
  
  def test_to_formatted_date
    d1 = ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS[:d1]
    d2 = ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS[:d2]
    d3 = ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS[:d3]
    
    assert_equal "10/01/07", '10/01/2007'.to_formatted_date(d1).to_s(:d1)
    assert_equal "10/01/07", '10/01/07'.to_formatted_date(d1).to_s(:d1)
    assert_equal "10/01/07", '01.10.07'.to_formatted_date(d2).to_s(:d1) 
    assert_equal "10/01/07", '01.10.2007'.to_formatted_date(d2).to_s(:d1)
    assert_equal "10/01/07", '2007-10-01'.to_formatted_date(d3).to_s(:d1)
    assert_equal "10/01/07", '07-10-01'.to_formatted_date(d3).to_s(:d1)
  end    
end
