require File.dirname(__FILE__) + '/../spec_helper'

describe FormSignupField do
  before(:each) do
    @form_signup_field = FormSignupField.new(
      :field_type => "text_field",
      :key => "key",
      :order => 2,
      :title => "Test title 2"
    )
    @form_signup_field2 = FormSignupField.new(
      :field_type => "text_field",
      :key => "key1",
      :order => 1,
      :title => "Test title 1"
    )
  end

  it "should be valid" do
    @form_signup_field.should be_valid
  end

  it "shoud have 2 elements" do
    @form_signup_field.save
    @form_signup_field2.save
    binding.pry

    FormSignupField.all_with_order.count.should eq(2)
  end

  it "fields should be in proper order" do
    @form_signup_field.save
    @form_signup_field2.save
    binding.pry

    fields = FormSignupField.all_with_order
    fields[0].title.should eq("Test title 2")
    fields[1].title.should eq("Test title 1")
  end

  describe "field_type is collection_select" do
    before(:each) do |variable|
      @select_field = FormSignupField.new(
        :field_type => "collection_select",
        :key => "key2",
        :order => 2,
        :title => "Test title 3",
        :options => "ka, ma, la"
      )
    end

    it "should not validate" do
      @select_field.should be_valid
    end

    it "should get proper list for dropdown" do
      result = @select_field.get_options_for_dropdown
      result.should eq(['ka', 'ma', 'la'])
    end
  end
end