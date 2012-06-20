require 'spec_helper'

describe Object do
  before       { Delayed::Job.delete_all }

  it "should call #delay on methods which are wrapped with handle_asynchronously" do
    story = Story.create :text => 'Once upon...'
  
    Delayed::Job.count.should == 0
  
    story.whatever(1, 5)
  
    Delayed::Job.count.should == 1
    job =  Delayed::Job.first
    job.payload_object.class.should   == Delayed::PerformableMethod
    job.payload_object.method.should  == :whatever_without_delay
    job.payload_object.args.should    == [1, 5]
    job.payload_object.perform.should == 'Once upon...'
  end

  context "delay" do
    it "should raise a ArgumentError if target method doesn't exist" do
      lambda { Object.new.delay.method_that_does_not_exist }.should raise_error(NoMethodError)
    end

    it "should add a new entry to the job table when delay is called on it" do
      lambda { Object.new.delay.to_s }.should change { Delayed::Job.count }.by(1)
    end

    it "should add a new entry to the job table when delay is called on the class" do
      lambda { Object.delay.to_s }.should change { Delayed::Job.count }.by(1)
    end
    
    it "should set job options" do
      run_at = 1.day.from_now
      job = Object.delay(:priority => 20, :run_at => run_at).to_s
      job.run_at.should == run_at
      job.priority.should == 20
    end
    
    it "should save args for original method" do
      job = 3.delay.+(5)
      job.payload_object.args.should == [5]
    end
  end
end
