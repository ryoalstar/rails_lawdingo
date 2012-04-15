class QuestionsController < ApplicationController
  def create
    @question = Question.new(params[:question])
    @question.save

    if logged_in?
      UserMailer.new_question_email(@question).deliver
      respond_to :js
    else
      session[:question_id] = @question.to_param
      redirect_to new_user_path(ut: 0)
    end
  end
end
