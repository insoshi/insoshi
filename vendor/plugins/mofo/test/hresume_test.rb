require File.dirname(__FILE__) + '/test_helper'
require 'mofo/hresume'

context "A parsed hResume object" do
  setup do 
    $hresume ||= HResume.find(:first => fixture(:hresume))
  end

  fields = { 
    :contact    => HCard,
    :education  => HCalendar,
    :experience => Array,
    :summary    => String,
    :skills     => String 
  }

  fields.each do |field, klass|
    specify "should have an #{klass} for #{field}" do
      $hresume.send(field).should.not.be.nil
      $hresume.send(field).should.be.an.instance_of klass
    end
  end
end
