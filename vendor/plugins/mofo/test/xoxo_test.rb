require File.dirname(__FILE__) + '/test_helper'
require 'mofo/xoxo'

context "A simple xoxo object" do
  setup do
    @xoxo = XOXO.find(:text => '<ol> <li><a href="http://diveintomark.org/xml/blink.xml" type="application/rss+xml">dive into mark b-links</a></li> <li><a href="http://www.thauvin.net/blog/xml.jsp?format=rdf" type="application/rss+xml">Eric&#39;s Weblog</a></li> <li><a href="http://intertwingly.net/blog/index.rss2" type="application/rss+xml">Sam Ruby</a></li> <li><a href="http://diveintomark.org/xml/atom.xml" type="application/atom+xml">dive into mark</a></li> <li><a href="http://www.decafbad.com/blog/index.rss" type="application/rss+xml">0xDECAFBAD</a></li> </ol>')
  end

  specify "should have five label elements" do
    @xoxo.size.should.equal 5
    classes = @xoxo.map { |x| x.class }.uniq
    classes.size.should.equal 1
    classes.first.should.equal XOXO::Label
  end
end

context "A simple xoxo object with two nested LIs" do
  setup do
    @xoxo = XOXO.find(:text => '<ol> <li><p>Linkblogs</p> <ol> <li><a href="http://diveintomark.org/xml/blink.xml" type="application/rss+xml">dive into mark b-links</a></li> <li><a href="http://www.thauvin.net/blog/xml.jsp?format=rdf" type="application/rss+xml">Eric&#39;s Weblog</a></li> </ol> </li> <li><p>Weblogs</p> <ol> <li><a href="http://intertwingly.net/blog/index.rss2" type="application/rss+xml">Sam Ruby</a></li> <li><a href="http://diveintomark.org/xml/atom.xml" type="application/atom+xml">dive into mark</a></li> <li><a href="http://www.decafbad.com/blog/index.rss" type="application/rss+xml">0xDECAFBAD</a></li> </ol> </li> </ol>')
  end

  specify "should be a two element array of hashes" do
    @xoxo.size.should.equal 2
  end

  specify "have hashes with two and three strings respectively" do
    @xoxo.first.should.be.an.instance_of Hash
    @xoxo.first["Linkblogs"].should.be.an.instance_of Array
    @xoxo.first["Linkblogs"].size.should.be 2
    @xoxo.last["Weblogs"].size.should.be 3
  end
end

context "An array of xoxo objects created from a full webpage identified by class" do
  setup do
    @xoxo = XOXO.find(fixture(:chowhound), :class => true)
  end

  specify "should not be empty" do
    @xoxo.size.should.be > 0
  end

  specify "should be four arrays of arrays" do
    @xoxo.size.should.equal 4
    @xoxo.map { |x| x.class }.uniq.first.should.equal Array
  end
end

#' <ul id="ol1"> <li> Two <ul> <li>Sub 1</li> <li> Sub 2 <ul> <li>Sub C3</li> <li>Sub C4</li> </ul> </li> <li>Sub 3</li> <li>Sub 4</li> </ul> </li> <li>One</li> <li> Four <ul> <li>Sub D1</li> <li>Sub D2</li> <li> Sub D4 <ol> <li>Sub C1</li> <li>Sub C2</li> <li> Sub C3 <ul> <li>Sub B1</li> <li> Sub B2 <ul> <li>Sub B1</li> <li>Sub B3</li> <li>Sub B4</li> </ul> </li> <li>Sub B3</li> <li>Sub B4</li> </ul> </li> <li>Sub C4</li> </ol> </li> </ul> </li> <li> Three <ul> <li>Sub B1</li> <li>Sub B3</li> <li>Sub B4</li> </ul> </li> </ul> '
