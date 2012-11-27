module MessageHelper

  def start_or_schedule_button_text(lawyer)
    if logged_in? && current_user.is_lawyer?
      link_to "Send a note or ask a question", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
    else
      link_to "Send a note or ask a question", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "dialog-opener "
    end
  end

   #Note/Question buttons
  def start_or_schedule_button_text_profile(lawyer)
    if logged_in? && current_user.is_lawyer?
      link_to "", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
    else
      link_to "", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "dialog-opener "
    end
  end

  def start_or_schedule_button_text_profile_text(lawyer)
    if logged_in? && current_user.is_lawyer?
      link_to "Send a note or ask a question", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
    else
      link_to "Send a note or ask a question", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "dialog-opener"
    end
  end

  def send_message_from_lawyer_mini_profile lawyer
    message = Message.new(:lawyer => lawyer)
    message.client = current_user if logged_in? && current_user.is_client?
    render 'messages/form', :message => message
  end
  
end
