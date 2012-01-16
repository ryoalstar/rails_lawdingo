module LawyersHelper
  def selected_lawyers_caption
    state = ""
    area = ""
    speciality = ""

    # Lawyers count
    if @lawyers.present?
      lawyers_count = @lawyers.count.to_s
      lawyers_str = @lawyers.count > 1 ? "lawyers" : "lawyer"
    end

    # State
    if params[:select_state].present? && params[:select_state].to_i != 0
      state = State.find(params[:select_state].to_i)
      state = " #{state.name}"
    end

    # Practice area
    if params[:select_pa].present? && params[:select_pa].to_i != 0
      area = PracticeArea.find(params[:select_pa].to_i)
      area = " #{area.name}"
    end

    # Speciality
    if params[:select_sp].present? && params[:select_sp].to_i != 0
      speciality = PracticeArea.find(params[:select_sp].to_i)
      speciality = " on #{speciality.name}"
    end

    "There are #{lawyers_count}#{state}#{area} #{lawyers_str} who can offer you legal advice#{speciality} right now."
  end

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
