require File.dirname(__FILE__) + '/../spec_helper'

describe PostsHelper do
  
  #Delete this example and add some real ones or delete this file
  it "should include the PostHelper" do
    included_modules = (class << helper; self; end).send :included_modules

    included_modules.should include(PostsHelper)
  end
  
end
