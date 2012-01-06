module LawyersHelper
  def start_or_schedule_button(lawyer)
    if lawyer.is_online? && !lawyer.is_busy
      if logged_in?
        link_to "Start Video Consultation", user_chat_session_path(lawyer), :title => "Start Video Consultation", :class => 'button'
      else
        link_to "Start Video Consultation", new_user_path, :title => "Start Video Consultation", :class => 'button'
      end
    else
      if logged_in?
        link_to "Schedule Consultation", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "dialog-opener button yellow"
      else
        link_to "Schedule Consultation", new_user_path, :class => "button yellow"
      end
    end
  end
end
