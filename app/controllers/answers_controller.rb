class AnswersController < ApplicationController
  def create
    @answer = Answer.new(params[:answer])
    @answer.save
    puts @answer.errors.to_json
    redirect_to lawyer_answer_path(current_user, :question_id=>@answer.question.id)
  end
end
      
  