require File.dirname(__FILE__) + '/test_helper'
require 'mofo/hentry'

context "A parsed hEntry object" do
  setup do
    $hentry ||= HEntry.find(:first => fixture(:hatom))
  end

  specify "should have a title" do
    $hentry.entry_title.should.equal "&ldquo;A Rails Toolbox&rdquo;"
  end

  specify "should have an author string " do
    $hentry.author.should.be.an.instance_of HCard
    $hentry.author.fn.should.equal "Chris"
  end

  specify "should have content" do
    $hentry.entry_content.should.be.an.instance_of String
  end

  specify "should have an attached published date object" do
    $hentry.published.should.be.an.instance_of Time
  end

  specify "should have an inferred updated attribute which references the published date object" do
    $hentry.updated.should.be.an.instance_of Time
    $hentry.updated.should.be $hentry.published
  end

  specify "should have a bookmark (permalink)" do
    $hentry.bookmark.should.equal "/post/13"
  end

  specify "should have an array of tags" do
    $hentry.tags.should.be.an.instance_of Array
  end
end
