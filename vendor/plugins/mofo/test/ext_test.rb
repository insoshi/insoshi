require File.dirname(__FILE__) + '/test_helper'
require 'microformat/string'
require 'microformat/array'
require 'mofo/hcard'
require 'mofo/hcalendar'
require 'mofo/hentry'

context "A string should be coercable into" do
  specify "an integer" do
    "2".coerce.should.equal 2
  end

  specify "a float" do
    "4.0".coerce.should.equal 4.0
    "4,0".coerce.should.not.equal 4.0
  end

  specify "a datetime" do
    "2004-08-03T03:48:27Z".coerce.should.equal Time.parse("2004-08-03T03:48:27Z")
    "1985-03-13".coerce.should.equal Time.parse("1985-03-13")
  end

  specify "a boolean" do
    "true".coerce.should.be true
    "false".coerce.should.be false
  end
end

context "A string with HTML" do
  specify "should be able to remove the HTML" do
    string = %[<ol> <li><a href="http://diveintomark.org/xml/blink.xml" type="application/rss+xml">dive into mark b-links</a></li> <li><a href="http://www.thauvin.net/blog/xml.jsp?format=rdf" type="application/rss+xml">Eric&#39;s Weblog</a></li> <li><a href="http://intertwingly.net/blog/index.rss2" type="application/rss+xml">Sam Ruby</a></li> <li><a href="http://diveintomark.org/xml/atom.xml" type="application/atom+xml">dive into mark</a></li> <li><a href="http://www.decafbad.com/blog/index.rss" type="application/rss+xml">0xDECAFBAD</a></li> </ol>]
    string.strip_html.strip.should.equal "dive into mark b-links Eric&#39;s Weblog Sam Ruby dive into mark 0xDECAFBAD"
  end
end

context "An array sent first_or_self" do
  setup do
    @array = %w(one two)
  end

  specify "should return itself if it has more than one element" do
    @array.first_or_self.should.be @array
  end

  specify "should return its first element if it has only one element" do
    @array.pop
    @array.first_or_self.should.be.an.instance_of String
  end
end

context "Any defined h* microformat" do
  specify "should have a lowercase h* method, for fun" do 
    hCard.should.equal HCard
    hCalendar.should.equal HCalendar
  end
end

context "Searching a page with multiple uformats using Microformat.find" do
  setup do
    $multi_formats ||= Microformat.find(fixture(:chowhound))
  end

  specify "should find all the instances of the different microformats" do
    $multi_formats.should.be.an.instance_of Array
    classes = $multi_formats.map { |i| i.class }
    classes.should.include HEntry
    classes.should.include HCard
  end
end

context "Mofo's timeout duration" do
  specify "should be alterable" do
    Timeout.expects(:timeout).at_least_once.with(5)
    Microformat.find('random_file.html') 

    Microformat.timeout = 11
    Timeout.expects(:timeout).at_least_once.with(11)
    Microformat.find('random_file.html') 
  end
end
