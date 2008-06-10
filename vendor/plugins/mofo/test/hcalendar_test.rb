require File.dirname(__FILE__) + '/test_helper'
require 'mofo/hcalendar'

context "A parsed hCalendar object with an embedded hCard" do
  setup do
    $hcalendar_hcard ||= HCalendar.find(:first => fixture(:upcoming_single))
  end
  
  specify "should have an HCard for its location" do
    $hcalendar_hcard.location.should.be.an.instance_of HCard
  end
end

context "A parsed hCalendar object with embedded adr" do
  setup do
    $hcalendar_addr ||= HCalendar.find(:first => fixture(:event_addr))
  end
  
  specify "should have an Adr for its location" do
    $hcalendar_addr.location.should.be.an.instance_of Adr
  end
end

context "A parsed hCalendar object with string location" do
  setup do
    $hcalendar_string ||= HCalendar.find(:first => fixture(:upcoming))
  end
  
  specify "should have a string for its location" do
    $hcalendar_string.location.should.be.an.instance_of String
    $hcalendar_string.location.should.not.be.empty
  end
end
