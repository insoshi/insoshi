require File.dirname(__FILE__) + '/test_helper'
require 'mofo/hcard'

module Formats
  class Card < HCard
  end
end

context "Subclassing an hCard" do
  specify "should parse a page with an hcard" do
    proc { Formats::Card.find(fixture(:fauxtank)) }.should.not.raise MicroformatNotFound
  end

  specify "should raise an error if no hcard is found in strict mode" do
    proc { Formats::Card.find(fixture(:fake), :strict => true) }.should.raise MicroformatNotFound
  end

  specify "should return an empty array if no hcard is found" do
    Formats::Card.find(fixture(:fake)).should.equal []
  end

  specify "should return nil if no hcard is found with :first" do
    Formats::Card.find(:first => fixture(:fake)).should.equal nil
  end

  specify "should return nil if no hcard is found with :all" do
    Formats::Card.find(:all => fixture(:fake)).should.equal []
  end

  specify "should accept a :text option" do
    Formats::Card.find(:text => open(fixture(:fauxtank)).read).should.not.equal []
    Formats::Card.find(:text => open(fixture(:fauxtank)).read).should.not.equal nil
  end
end
