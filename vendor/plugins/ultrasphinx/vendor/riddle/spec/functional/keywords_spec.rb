require 'spec/spec_helper'

describe "Sphinx Keywords" do
  before :each do
    @client = Riddle::Client.new("localhost", 3313)
  end
  
  it "should return an array of hashes" do
    results = @client.keywords("pat", "people")
    results.should be_kind_of(Array)
    
    results.each do |result|
      result.should be_kind_of(Hash)
    end
  end
  
  it "should have keys for normalised and tokenised versions of the keywords" do
    results = @client.keywords("pat", "people")
    results.each do |result|
      result.keys.should include(:normalised)
      result.keys.should include(:tokenised)
    end
  end
  
  it "shouldn't have docs or hits keys if not requested" do
    results = @client.keywords("pat", "people")
    results.each do |result|
      result.keys.should_not include(:docs)
      result.keys.should_not include(:hits)
    end
  end
  
  it "should have docs and hits keys if requested" do
    results = @client.keywords("pat", "people", true)
    results.each do |result|
      result.keys.should include(:docs)
      result.keys.should include(:hits)
    end
  end
end