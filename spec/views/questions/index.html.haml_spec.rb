require 'spec_helper'

describe "questions/index" do

  before(:each) do
    view.stubs(
      :current_user => lawyer,
      :action_name => "index",
      :controller_name => "questions"
    )
    assign(:lawyer, lawyer)
    assign(:questions, lawyer.matching_questions)
  end

  let(:lawyer) do
    lawyer = Lawyer.new
    lawyer.stubs(:id => 14)
    lawyer.stubs(:matching_questions => [FactoryGirl.create(:question)])
   
    lawyer
  end

  it "should have link to the URL of the question" do
    render
    
    path = new_question_answer_path(lawyer.matching_questions.first.id)
    rendered.should have_selector("a[href='#{path}']")

  end

end