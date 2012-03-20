require 'spec_helper'
require 'backend/shared_backend_spec'
require 'delayed/backend/mongo_mapper'

describe Delayed::Backend::MongoMapper::Job do
  before(:all) do
    @backend = Delayed::Backend::MongoMapper::Job
  end

  before(:each) do
    MongoMapper.database.collections.each(&:remove)
  end

  it_should_behave_like 'a backend'

  describe "indexes" do
    it "should have combo index on priority and run_at" do
      @backend.collection.index_information.detect { |index| index[0] == 'priority_1_run_at_1' }.should_not be_nil
    end

    it "should have index on locked_by" do
      @backend.collection.index_information.detect { |index| index[0] == 'locked_by_1' }.should_not be_nil
    end
  end

  describe "delayed method" do
    class MongoStoryReader
      def read(story)
        "Epilog: #{story.tell}"
      end
    end

    class MongoStory
      include ::MongoMapper::Document
      key :text, String

      def tell
        text
      end
    end

    it "should ignore not found errors because they are permanent" do
      story = MongoStory.create :text => 'Once upon a time...'
      job = story.delay.tell
      story.destroy
      lambda { job.invoke_job }.should_not raise_error
    end

    it "should store the object as string" do
      story = MongoStory.create :text => 'Once upon a time...'
      job = story.delay.tell

      job.payload_object.class.should   == Delayed::PerformableMethod
      job.payload_object.object.should  == story
      job.payload_object.method.should  == :tell
      job.payload_object.args.should    == []
      job.payload_object.perform.should == 'Once upon a time...'
    end

    it "should store arguments as string" do
      story = MongoStory.create :text => 'Once upon a time...'
      job = MongoStoryReader.new.delay.read(story)
      job.payload_object.class.should   == Delayed::PerformableMethod
      job.payload_object.method.should  == :read
      job.payload_object.args.should    == [story]
      job.payload_object.perform.should == 'Epilog: Once upon a time...'
    end
  end

  describe "before_fork" do
    after do
      MongoMapper.connection.connect
    end

    it "should disconnect" do
      lambda do
        Delayed::Backend::MongoMapper::Job.before_fork
      end.should change { !!MongoMapper.connection.connected? }.from(true).to(false)
    end
  end

  describe "after_fork" do
    before do
      MongoMapper.connection.close
    end

    it "should call reconnect" do
      lambda do
        Delayed::Backend::MongoMapper::Job.after_fork
      end.should change { !!MongoMapper.connection.connected? }.from(false).to(true)
    end
  end

end
