require 'spec_helper'

describe QuestionsController do
  before :each do
    @question = FactoryGirl.create(:question)
  end

  context "on asking a question" do
    it "should notify admin by email" do
      expect {
        xhr :get, :create, question: @question.attributes
      }.to change(ActionMailer::Base.deliveries, :size).by(1)

      question_email = ActionMailer::Base.deliveries.last
      question_email.to[0].should == "nikhil.nirmel@gmail.com"
    end

    it "should render notice template" do
      xhr :get, :create, question: @question.attributes
      should render_template "create"
    end
  end
end
