class QuestionsController < ApplicationController
  before_filter :authenticate, :only => [:options, :update]
  def create
    @question = Question.new(params[:question])
    @question.state_name = params[:question][:state_name] if params[:question][:state_name].present?
    @question.practice_area = params[:question][:practice_area] if params[:question][:practice_area].present?
    @question.save
    
    if logged_in?
      UserMailer.new_question_email(@question).deliver
      render :options
    else
      session[:question_id] = @question.to_param
      redirect_to new_client_path, :notice => "To submit that inquiry please sign up with or log in to Lawdingo."
    end
  end

  def update
    @question = Question.find(params[:id])
    @question.update_attributes(params[:question])

    respond_to :js
  end
 
  def options
    @question = Question.find params[:id] || not_found
  end

end
