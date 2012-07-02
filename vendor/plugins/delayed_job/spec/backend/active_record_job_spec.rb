require 'spec_helper'
require 'backend/shared_backend_spec'
require 'delayed/backend/active_record'

describe Delayed::Backend::ActiveRecord::Job do
  before(:all) do
    @backend = Delayed::Backend::ActiveRecord::Job
  end
  
  before(:each) do
    Delayed::Backend::ActiveRecord::Job.delete_all
    SimpleJob.runs = 0
  end
  
  after do
    Time.zone = nil
  end
  
  it_should_behave_like 'a backend'

  context "db_time_now" do
    it "should return time in current time zone if set" do
      Time.zone = 'Eastern Time (US & Canada)'
      %w(EST EDT).should include(Delayed::Job.db_time_now.zone)
    end
    
    it "should return UTC time if that is the AR default" do
      Time.zone = nil
      ActiveRecord::Base.default_timezone = :utc
      Delayed::Backend::ActiveRecord::Job.db_time_now.zone.should == 'UTC'
    end

    it "should return local time if that is the AR default" do
      Time.zone = 'Central Time (US & Canada)'
      ActiveRecord::Base.default_timezone = :local
      %w(CST CDT).should include(Delayed::Backend::ActiveRecord::Job.db_time_now.zone)
    end
  end
  
  describe "after_fork" do
    it "should call reconnect on the connection" do
      ActiveRecord::Base.connection.should_receive(:reconnect!)
      Delayed::Backend::ActiveRecord::Job.after_fork
    end
  end
end
