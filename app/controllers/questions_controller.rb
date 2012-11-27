class QuestionsController < ApplicationController
  before_filter :authenticate, :only => [:options, :update]
  
  def index
    @lawyer = Lawyer.find(params[:lawyer_id]) 
    @questions = @lawyer.matching_questions
  end
  
  def create
    @question = Question.new(params[:question])
    @question.state_name = params[:question][:state_name] if params[:question][:state_name].present?
    @question.practice_area = params[:question][:practice_area] if params[:question][:practice_area].present?
    @question.user_id = current_user.id if (current_user.present? && @question.user_id.nil?)
    @question.save
    
    if logged_in?
      UserMailer.new_question_email(@question).deliver
      @stripe_plan = Client::get_stripe_plan '4'
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
    @stripe_plan = Client::get_stripe_plan '4'
    @question = Question.find params[:id] || not_found
  end

end
