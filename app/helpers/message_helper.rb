module MessageHelper

  def start_or_schedule_button_text(lawyer)
    if logged_in?
      link_to "Send a note or ask a question", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "dialog-opener "
    else
      link_to "Send a note or ask a question", new_client_path(notice: true, return_path: attorney_path(lawyer, slug: lawyer.slug), lawyer_path: lawyer.id), :class => ''
    end
  end

   #Note/Question buttons
  def start_or_schedule_button_text_profile(lawyer)
    if logged_in?
      link_to "", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "dialog-opener "
    else
      link_to "", new_client_path(notice: true, return_path: attorney_path(lawyer, slug: lawyer.slug), lawyer_path: lawyer.id), :class => ''
    end
  end

  def start_or_schedule_button_text_profile_text(lawyer)
    if logged_in?
      link_to "Send a note or ask a question", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "dialog-opener"
    else
      link_to "Send a note or ask a question", new_client_path(notice: true, return_path: attorney_path(lawyer, slug: lawyer.slug), lawyer_path: lawyer.id), :class => ''
    end
  end

  def send_message_from_lawyer_mini_profile lawyer
    message = Message.new(:lawyer => lawyer)
    message.client = current_user if current_user && current_user.is_client?
    render 'messages/form', :message => message
  end  
  
end
