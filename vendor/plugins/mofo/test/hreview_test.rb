require File.dirname(__FILE__) + '/test_helper'
require 'mofo/hreview'

context "The parsed Firesteed hReview object" do
 setup do
   $firesteed ||= HReview.find(:first => fixture(:corkd), :base => 'http://www.corkd.com')
 end

  specify "should have a valid, coerced dtreviewed field" do
    $firesteed.dtreviewed.should.be.an.instance_of Time
    $firesteed.dtreviewed.should.be <= Time.parse('20060518')
  end

  specify "should have a rating of 5" do
    $firesteed.rating.should.equal 5
  end

 specify "should have a description" do
   $firesteed.description.should.equal %[This is probably my favorite every day (well, not every day) wine.  It's light, subtly sweet, ripe fruit, slightly spicy oak.  It's a bit "slippery", if that makes sense (in a very good way).  Highly drinkable.]
  end

  specify "should have an HCard as the reviewer" do
    $firesteed.reviewer.fn.should.equal "simplebits"
    $firesteed.reviewer.photo.should.equal "http://flickr.com/img/icon-user-64.gif"
    $firesteed.reviewer.url.should.equal "http://www.corkd.com/people/simplebits"
  end

  specify "should have a valid item" do
    $firesteed.item.fn.should.equal "Firesteed 2003 Pinot Noir"
  end

  specify "should have 7 tags" do
    $firesteed.tags.size.should.equal 7
    $firesteed.tags.first.should.equal "berry"
    $firesteed.tags.last.should.equal "sweet"
  end
end
