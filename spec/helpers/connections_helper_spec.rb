require File.dirname(__FILE__) + '/../spec_helper'

describe ConnectionsHelper do
  
  #Delete this example and add some real ones or delete this file
  it "should include the ConnectionHelper" do
    included_modules = (class << helper; self; end).send :included_modules

    included_modules.should include(ConnectionsHelper)
  end
  
end
