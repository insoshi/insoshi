require File.dirname(__FILE__) + '/test_helper'
require 'mofo/hreview'

alias :real_open :open
def open(input)
  input[/^http/] ? open(fixture(:corkd)) : real_open(input)
end

context "Grabbing an hReview from a URL" do
  setup do
    url = 'http://www.corkd.com/views/123'
    $url_hreview ||= HReview.find(:first => url)
  end

  specify "should add the base URL to all nested relative links" do
    $url_hreview.reviewer.url.should.equal 'http://www.corkd.com/people/simplebits'
  end

  specify "should not add the base URL to absolute links" do
    $url_hreview.reviewer.photo.should.equal 'http://flickr.com/img/icon-user-64.gif'
  end
end
