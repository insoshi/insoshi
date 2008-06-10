require File.dirname(__FILE__) + '/test_helper'
require 'mofo/hcard'

context "Multiple attributes within a container" do
  setup do
    $hcards    ||= HCard.find(:all => fixture(:hresume))
    $included  ||= $hcards.first
    $including ||= $hcards[1]
  end

  specify "should be referenceable by a microformat using the include pattern" do
    %w(fn n).each do |att|
      $including.send(att).should.equal $included.send(att)
    end
  end
end

context "A single attribute" do
  setup do
    $horsed ||= HCard.find(:first => fixture(:include_pattern_single_attribute))
  end

  specify "should be referenceable by a microformat using the include pattern" do
    $horsed.logo.should.not.be.nil
    $horsed.logo.should.equal Hpricot(open(fixture(:include_pattern_single_attribute))).at("#logo").attributes['src']
  end
end
