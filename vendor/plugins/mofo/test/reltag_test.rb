require File.dirname(__FILE__) + '/test_helper'
require 'mofo/rel_tag'

context "An array of reltag arrays created from the corkd review webpage" do
  setup do
    $tags ||= RelTag.find(:all => fixture(:corkd))
  end

  specify "should consist of 23 tags" do
    $tags.size.should.equal 23 
  end

  specify "should include the berry and slippery tags" do
    $tags.flatten.should.include 'berry'
    $tags.flatten.should.include 'slippery'
  end
end

context "A web page with three rel tags" do
  setup do 
    $page ||= <<-EOF
    <html>
    <body>
    <ul>
      <li><a href="/tags/miracle" rel="tag">miracle</a></li>
      <li><a href="/tags/wonder" rel="tag">wonder</a></li>
      <li><a href="/tags/amusement" rel="tag">amusement</a></li>
    </ul>
    </body>
    </html>
    EOF
  end

  specify "should produce an array of three RelTag objects" do
    tags = RelTag.find(:all, :text => $page)
    tags.should.be.an.instance_of Array
    tags.size.should.equal 3
    tags.should.equal ["miracle", "wonder", "amusement"]
  end
end
