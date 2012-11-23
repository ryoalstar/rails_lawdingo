class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_admin, :logged_in?, :logged_in_admin?

  def set_timezone
    Time.zone = current_user.nil? ? "Eastern Time (US & Canada)" : current_user.try(:time_zone)  || "Eastern Time (US & Canada)" 
  end
  
  unless Rails.application.config.consider_all_requests_local
     rescue_from ActionController::RoutingError, with: :render_404
     rescue_from ActionController::UnknownController, with: :render_404
     rescue_from ActionController::UnknownAction, with: :render_404
     rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end
  
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  
  # log in a given user
  def log_in_user!(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def update_tokbox_session user
    tokbox_info = get_tokbox_info
    tokbox_session_id = tokbox_info[0]
    tokbox_token = tokbox_info[1]

    user.update_attributes(
      :tb_session_id => tokbox_session_id,
      :tb_token => tokbox_token,
      :call_status => ''
    )
    session[:user_id] = user.id
  end


  def get_tokbox_info
    require "yaml"
    config = YAML.load_file(File.join(Rails.root, "config", "tokbox.yml"))
    @opentok=OpenTok::OpenTokSDK.new config['API_KEY'],config['SECRET']
    @location=config['LOCATION']
    begin
      session_id = @opentok.create_session(@location)
      token = @opentok.generate_token :session_id => session_id, :expire_time=>(Time.now+2.day).to_i
    rescue => e
      Rails.logger.error(e.message)
      Rails.logger.error(config)
      Rails.logger.error(e.backtrace[0..10])
      session_id = ""
      token = ""
    end
    return [session_id.to_s,token.to_s]
  end


  def current_user
    return nil if session[:user_id].blank?
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def authenticate
    if logged_in?
      current_user.update_attribute(:last_online, Time.now)
    else
      access_denied
    end
    #logged_in? ? true : access_denied
  end

  def login_in_user user
    user.update_attributes(:is_online => true, :is_available_by_phone => true, :last_login => Time.now, :last_online => Time.now)
    session[:user_id] = user.id
  end

  def logout_user
    return false unless current_user.present?
    current_user.update_attributes(:is_online => false, :is_busy =>false, :peer_id =>'0', :last_online => Time.now)
    session[:user_id] = nil
  end

  def reset_user_session user
    user.update_attributes(:is_online => false, :is_busy =>false, :peer_id =>'0')
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
      redirect_to "/questions/#{question.id}/options"
    end
  end
  
  def render_404
    respond_to do |format|
      format.html { render template: 'errors/error_404', layout: 'layouts/application', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  # send message from guest to lawyer
  def send_message user
    return false unless user.is_a?(Client)
    return false unless session[:message_id]
    message = Message.find(session.delete(:message_id))
    message.update_attribute(:client_id, user.id)
    if message.send!
      session[:return_to] = attorney_path(message.lawyer, slug: message.lawyer.slug)
      flash[:notice] = 'Your message has been sent.' 
    end
  end
  
  def lawyers_path?
    request.path == lawyers_path
  end
  
  def current_path? path
    request.path == path
  end
  
  def auto_detect_state
    if request.location.present? && request.location.state_code.present?
      @auto_detected_state = State.find_by_abbreviation(request.location.state_code)
    end
  end
  
  def only_client
    redirect_to lawyers_path, :notice => "This page only for Client" unless current_user.try(:is_client?)
  end
  
  def only_lawyer
    redirect_to lawyers_path, :notice => "This page only for Lawyer!" unless current_user.try(:is_lawyer?)
  end
  
  def check_for_notices
    flash[:notice] = params[:notice] if params[:notice]
    flash[:alert] = params[:alert] if params[:alert]
  end

end
