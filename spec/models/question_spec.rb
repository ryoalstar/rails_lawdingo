require 'spec_helper'

describe Question do
  DatabaseCleaner.clean

  it "creates an inquiry after saving new question" do
    @question = FactoryGirl.create(:question)
    @question.inquiry.should be_present
  end
  
  it "should not create a question without body" do
    @question = FactoryGirl.build(:question)
    @question.body = nil
    @question.should_not be_valid
  end
  it "should not create a question without state" do
    @question = FactoryGirl.build(:question)
    @question.state_name = nil
    @question.should_not be_valid
  end
end
