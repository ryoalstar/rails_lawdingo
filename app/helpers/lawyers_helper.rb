module LawyersHelper
  def practice_areas_listing(lawyer)
    areas = lawyer.practice_areas.parent_practice_areas unless lawyer.practice_areas.blank?
    areas_names = areas.map do |area|
      area.name.downcase
    end

    last_area_name = areas_names.pop
    areas_names.empty? ? last_area_name : "#{areas_names.join(', ')} and #{last_area_name}"
  end

  def start_or_schedule_button(lawyer)
    if lawyer.is_online? && !lawyer.is_busy
      if logged_in?
        link_to "Start Video Consultation", user_chat_session_path(lawyer), :title => "Start Video Consultation", :class => 'button'
      else
        link_to "Start Video Consultation", new_user_path, :title => "Start Video Consultation", :class => 'button'
      end
    else
      if logged_in?
        link_to "Schedule Consultation", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "dialog-opener button blue"
      else
        link_to "Schedule Consultation", new_user_path, :class => "button blue"
      end
    end
  end
end
