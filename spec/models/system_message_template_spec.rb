require File.dirname(__FILE__) + '/../spec_helper'

describe SystemMessageTemplate do

  it "should not have validate without variables" do
    smt = SystemMessageTemplate.new
    smt.text = "test"
    smt.title = "test"
    smt.valid?.should_not == true
    # @system_message_template.valid?.should_not == true
  end

  it "should not have validate without message_type" do
    smt = SystemMessageTemplate.new
    smt.text = "{{req_name}}"
    smt.title = "{{request_url}}"
    smt.valid?.should_not == true
  end

  it "should not have validate without message_type" do
    smt = system_message_templates(:accepted)
    smt.valid?.should == true
  end

  it "should generate proper trigger offered subject and text" do
    smt = system_message_templates(:offered)
    title = smt.trigger_offered_subject("1","2")
    text = smt.trigger_content("3")
    title.should eq("2")
    text.should eq("3")
  end

  it "message_type should be unique" do
    smt1 = system_message_templates(:offered)
    smt2 = SystemMessageTemplate.new
    smt2.text = "{{req_name}}"
    smt2.title = "{{request_url}}"
    smt2.message_type = "offered"
    smt2.valid?.should_not == true
  end



  private 
    def create_system_message_template

    end
end