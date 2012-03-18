class QuestionsController < ApplicationController
  def create 
    @question = Question.new(params[:question])
    @question.save

    UserMailer.new_question_email(@question).deliver

    respond_to :js
  end
end
