require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PreferencesController do

  it "should require admin to access" do
    login_as :quentin
    get :index
    response.should redirect_to home_url
  end
end