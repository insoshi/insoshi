require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do

  describe "#first_n_words" do

    it "leaves short sentences untouched" do
      sentence = "a b  c   d"
      helper.first_n_words(sentence).should == sentence
    end

    it "shortens long sentences" do
      sentence = "a b  c   d " * 8
      sentence.strip!
      shortened = helper.first_n_words(sentence)
      shortened.should_not == sentence
      shortened.split.should have(20).words
      sentence.should start_with(shortened)
    end

    it "shortens long sentences (specified length)" do
      sentence = "a b  c   d " * 3
      sentence.strip!
      shortened = helper.first_n_words(sentence, 8)
      shortened.should_not == sentence
      shortened.split.should have(8).words
      sentence.should start_with(shortened)
    end

  end

end
