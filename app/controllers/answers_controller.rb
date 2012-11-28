class AnswersController < ApplicationController
  
  before_filter :authenticate
  before_filter :only_lawyer
  def new
    @lawyer = Lawyer.find(current_user.id) 
    @question = Question.find(params[:question_id])
    @answer = Answer.new
    
    @other_answers = Answer.all(:conditions=>{:question_id=>@question.id})
  end
  
  def create
    @answer = Answer.new(params[:answer])
    @answer.save

    redirect_to new_question_answer_path(@answer.question.id)
  end
end
      
  