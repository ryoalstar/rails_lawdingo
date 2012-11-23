class MessagesController < ApplicationController
  before_filter :only_client, :if => :logged_in?
  layout false
  def send_message_to_lawyer
    @lawyer = User.find params[:lawyer_id]
    message = Message.new(params[:message])
    message.client_id = current_user.id if current_user.present?
    message.save
    message.send! unless current_user.nil?
    session[:message_id] = message.id if message.is_a?(Message) && current_user.nil?
    flash[:notice] = "To send that message to #{@lawyer.first_name} #{@lawyer.last_name}, please tell us who you are." unless current_user.present?
    render :json => { :result => current_user.present?, :message => message }
  end

  def clear_session_message
    session.delete(:message_id) if session[:message_id]
    render :nothing => true
  end
end
