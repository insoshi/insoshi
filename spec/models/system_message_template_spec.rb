require File.dirname(__FILE__) + '/../spec_helper'

describe SystemMessageTemplate do
  
  before(:each) do
    @system_message_template = system_message_templates(:one)
  end

  it "should not have validate without variables" do
    @system_message_template.valid?.should_not == true
  end
end