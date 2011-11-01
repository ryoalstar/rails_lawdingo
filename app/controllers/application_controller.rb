class ApplicationController < ActionController::Base
  protect_from_forgery  

  helper_method :current_user, :current_admin, :logged_in? , :logged_in_admin?, :log_in_user, :log_out_user

  def log_in_user user_id
    session[:user_id] = user_id
  end

  def log_out_user
    session[:user_id] = nil
  end

  def current_user
    return unless session[:user_id]
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def authenticate
    logged_in? ? true : access_denied
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
    redirect_to login_path, :notice => 'You have not logged in' and return false
  end
  
end
