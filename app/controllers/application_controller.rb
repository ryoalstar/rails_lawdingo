class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_admin, :logged_in?, :logged_in_admin?, :log_in_user, :log_out_user

  def log_in_user user_id
    session[:user_id] = user_id
  end

  def log_out_user
    session[:user_id] = nil
  end

  def current_user
    return nil if session[:user_id].blank?
     @current_user ||= User.find_by_id(session[:user_id])
  end

  def authenticate
    if logged_in?
      current_user.update_attribute(:is_online,true)
    else
      access_denied
    end
    #logged_in? ? true : access_denied
  end

  def login_in_user user
    user.update_attributes(:is_online => true, :last_login => Time.now, :last_online => Time.now)
    session[:user_id] = user.id
  end

  def logout_user
    current_user.update_attributes(:is_online =>false, :is_busy =>false, :peer_id =>'0', :last_online => Time.now)
    session[:user_id] = nil
  end

  def reset_user_session user
    user.update_attributes(:is_online =>false, :is_busy =>false, :peer_id =>'0')
  end

  def authenticate_admin
    logged_in_admin? ? true : access_denied
  end

  def logged_in?
    current_user.is_a? User
  end

  def logged_in_admin?
    logged_in? and current_user.is_admin?
  end

  def access_denied
    session[:referred_url] = request.fullpath
    redirect_to login_path, :notice => 'You have not logged in' and return false
  end

  def send_pending_question(question_id, user)
    if question_id.present?
      question = Question.find(question_id)
      question.update_attribute(:user_id, user.id)

      UserMailer.new_question_email(question).deliver

      session[:question_id] = nil
    end
  end
end
