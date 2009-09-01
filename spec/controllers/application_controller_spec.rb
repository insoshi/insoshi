require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do
  it "should create a page view" do
    if request.format.html?
      lambda do
	PageView.create(:person_id => session[:person_id],
		  :request_url => request.request_uri,
		  :ip_address => request.remote_ip,
		  :referer => request.env["HTTP_REFERER"],
		  :user_agent => request.env["HTTP_USER_AGENT"])
      end
    end
  end
end
