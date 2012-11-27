require 'spec_helper'

describe "answers/new" do

  before(:each) do

    view.stubs(
      :current_user => lawyer,
      :action_name => "new",
      :controller_name => "answers"
    )
    assign(:lawyer, lawyer)
    assign(:question, question)
    assign(:answer, Answer.new)
    assign(:other_answers, [])
  end


  let(:question) do
    question = FactoryGirl.build_stubbed(:question)
    question
  end
  let(:lawyer) do
    lawyer = Lawyer.new
    lawyer.stubs(:id => 6)
    
    lawyer
  end

  it "should have form to new answer, title of the question" do
    render
    
    #path = new_question_answer_path(question.id)
    rendered.should have_selector("form[action='/answers']") 
    
    rendered.should have_selector("h2", :content=>question.body)
    
    
  end

end