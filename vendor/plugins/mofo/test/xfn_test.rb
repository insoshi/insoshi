require File.dirname(__FILE__) + '/test_helper'
require 'mofo/xfn'

def xfn_setup
  $xfn ||= XFN.find(:first => fixture(:xfn))
end

context "A XFN object" do
  setup do
    xfn_setup
  end

  specify "should know what relations it contains" do
    $xfn.relations.should.be.an.instance_of Array
    $xfn.relations.should.include 'me'
  end

  specify "should give information about a relationship" do
    me = $xfn.me
    me.should.be.an.instance_of Array
    me.first.relation.should.equal 'me'
    me.first.to_s.should.equal '#me'

    muse = $xfn.muse(true)
    muse.should.be.an.instance_of XFN::Link
    muse.relation.should.equal 'muse'
    muse.to_s.should.equal '#muse'
  end

  specify "should know relationship intersections" do
    # hot!
    intersection = $xfn.colleague_and_sweetheart
    intersection.should.be.an.instance_of XFN::Link
    intersection.to_s.should.equal '#colleague'

    intersection = $xfn.kin_and_colleague
    intersection.should.be.an.instance_of Array
    intersection.first.to_s.should.equal '#kin'
  end

  specify "should not know non-existent relationship intersections" do
    intersection = $xfn.colleague_and_sweetheart_and_muse_and_crush
    intersection.should.be.nil
  end

  specify "should not pick up reserved relationships" do
    $xfn.nofollow.should.be.nil
    $xfn.friend_and_nofollow.should.be.nil
    $xfn.bookmark.should.be.nil
  end
end

context "A XFN::Link object" do
  setup do
    xfn_setup
    $xfn_link ||= $xfn.first
  end

  specify "should be able to generate an html version of itself" do
    $xfn_link.to_html.should.match /href.+\>.+\</
  end

  specify "should know its name" do
    $xfn_link.name.should.be.an.instance_of String
    $xfn_link.name.should.not.be.empty
  end

  specify "should know its relation to the page from which it was obtained" do
    $xfn_link.relation.should.be.an.instance_of String
    $xfn_link.relation.should.not.be.empty
  end

  specify "should know where it points" do
    $xfn_link.link.should.be.an.instance_of String
    $xfn_link.link.should.not.be.empty
  end

  specify "should display itself as its link" do
    $xfn_link.to_s.should.equal $xfn_link.link.to_s
  end
end
