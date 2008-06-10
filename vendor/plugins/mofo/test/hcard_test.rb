require File.dirname(__FILE__) + '/test_helper'
require 'mofo/hcard'
require 'mofo/hreview'

context "A simple hcard definition" do
  specify "should parse a page with an hcard" do
    proc { HCard.find(fixture(:fauxtank)) }.should.not.raise MicroformatNotFound
  end

  specify "should raise an error if no hcard is found in strict mode" do
    proc { HCard.find(fixture(:fake), :strict => true) }.should.raise MicroformatNotFound
  end

  specify "should return an empty array if no hcard is found" do
    HCard.find(fixture(:fake)).should.equal []
  end

  specify "should return nil if no hcard is found with :first" do
    HCard.find(:first => fixture(:fake)).should.equal nil
  end

  specify "should return nil if no hcard is found with :all" do
    HCard.find(:all => fixture(:fake)).should.equal []
  end

  specify "should accept a :text option" do
    HCard.find(:text => open(fixture(:fauxtank)).read).should.not.equal []
    HCard.find(:text => open(fixture(:fauxtank)).read).should.not.equal nil
  end
end

context "The parsed fauxtank hCard object" do
  setup do
    $fauxtank ||= HCard.find(:first => fixture(:fauxtank))
  end

  specify "should be an instance of HCard" do
    $fauxtank.should.be.an.instance_of HCard
  end

  specify "should have `fauxtank' as the nickname" do
    $fauxtank.nickname.should.equal "fauxtank"
  end

  specify "should have two email addresses" do
    $fauxtank.email.size.should.equal 2
    $fauxtank.email.first.should.equal "fauxtank [at] gmail.com"
    $fauxtank.email.last.should.equal "chris [at] fauxtank.com"
  end
  
  specify "should have `Chris' as the given name" do
    $fauxtank.n.given_name.should.equal "Chris"
  end

  specify "should have `Murphy' as the family name" do
    $fauxtank.n.family_name.should.equal "Murphy"
  end

  specify "should have `Chicago' as the locality" do
    $fauxtank.adr.locality.should.equal "Chicago"
  end

  specify "should have `United States' as the country-name" do
    $fauxtank.adr.country_name.should.equal "United States"
  end

  specify "should have fauxtank's profile pic as the logo" do
    $fauxtank.logo.should.equal "http://static.flickr.com/25/buddyicons/89622800@N00.jpg?1128967902"
  end

  specify "should know what properties it found" do
    $fauxtank.properties.sort.should.equal ["fn", "note", "n", "email", "logo", "adr", "nickname", "title", "url"].sort
  end
end

context "The parsed Bob hCard object" do
  setup do
    $bob ||= HCard.find(:first => fixture(:bob))
  end
  
  specify "should have three valid emails with type information" do
    $bob.email.value.size.should.equal 3
    $bob.email.type.first.should.equal 'home'
    $bob.email.value.first.should.equal 'bob@gmail.com'
    $bob.email.type[1].should.equal 'work'
    $bob.email.value[1].should.equal 'robert@yahoo.com'
    $bob.email.type.last.should.equal 'home'
    $bob.email.value.last.should.equal 'bobby@gmail.com'
  end

  specify "should have two valid telephone numbers with type information" do
    $bob.tel.type.size.should.equal 2
    $bob.tel.type.first.should.equal 'home'
    $bob.tel.value.first.should.equal '707-555-9990'
    $bob.tel.type.last.should.equal 'cell'
    $bob.tel.value.last.should.equal '707-555-4756'
  end

  specify "should have a given, additional, and family name" do
    $bob.n.given_name.should.equal 'Robert'
    $bob.n.additional_name.should.equal 'Albert'
    $bob.n.family_name.should.equal 'Smith'
  end

  specify "should have a valid postal code" do
    $bob.adr.postal_code.should.equal '01234'
  end

  specify "should have a valid url" do
    $bob.url.should.equal "http://nubhub.com/bob"
  end
end

context "The parsed Stoneship hCard objects" do
  setup do
    $stoneship ||= HCard.find(:all => fixture(:stoneship))
  end

  specify "should only have String nicknames" do
    $stoneship.collect { |h| h.nickname }.compact.uniq.each do |nickname|
      nickname.should.be.an.instance_of String
    end
  end

  specify "should ignore broken urls" do
    $stoneship.first.logo.should.be.nil
  end
end

context "The parsed simple hCard object" do
  setup do
    $simple ||= HCard.find(:first => fixture(:simple))
  end

  specify "should have an org string" do
    $simple.org.should.be.an.instance_of String
    $simple.org.should.equal "Err the Blog"
  end

  specify "should have an email string" do
    $simple.email.should.be.an.instance_of String
    $simple.email.should.equal "chris[at]ozmm[dot]org"
  end

  specify "should have a valid name" do
    $simple.fn.should.equal "Chris Wanstrath"
  end

  specify "should have a valid url" do
    $simple.url.should.equal "http://ozmm.org/"
  end
end
