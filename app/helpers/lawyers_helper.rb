module LawyersHelper
  def selected_lawyers_caption
    state = ""
    area = ""
    speciality = ""

    # Lawyers count
    if @lawyers.present?
      lawyers_count = @lawyers.count.to_s
      lawyers_str = @lawyers.count > 1 ? "lawyers" : "lawyer"
      lawyers_verb = @lawyers.count > 1 ? "are" : "is"
    end

    # State

    # Depends on if the request came from the landing page or from
    # filter_result ajax function
    if params[:select_state].present?
      state_id = params[:select_state].to_i
    elsif params[:state].present?
      state_id = params[:state].to_i
    end

    if state_id.present? && state_id != 0
      state = State.find(state_id)
      state = " #{state.name}"
    end

    # Practice area
    if params[:select_pa].present?
      area_id = params[:select_pa].to_i
    elsif params[:pa].present?
      area_id = params[:pa].to_i
    end

    if area_id.present? && area_id != 0
      area = PracticeArea.find(area_id)
      area = " #{area.name.downcase}"
    end

    # Speciality
    if params[:select_sp].present?
      speciality_id = params[:select_sp].to_i
    elsif params[:sp].present?
      speciality_id = params[:sp].to_i
    end

    if speciality_id.present? && speciality_id != 0
      speciality = PracticeArea.find(speciality_id)
      speciality = " on #{speciality.name.downcase}"
    end

    if lawyers_count
      "There #{lawyers_verb} #{lawyers_count}#{state}#{area} #{lawyers_str} who can offer you legal advice#{speciality} right now."
    end
  end

  def practice_areas_listing(lawyer)
    areas = lawyer.practice_areas.parent_practice_areas unless lawyer.practice_areas.blank?
    areas_names = areas.map do |area|
      area.name.downcase
    end

    last_area_name = areas_names.pop
    areas_names.empty? ? last_area_name : "#{areas_names.join(', ')} and #{last_area_name}"
  end

  def free_message lawyer
    # if !lawyer.is_online && lawyer.phone.present?
    #   msg = "two minutes free, then:"
    # else
    #   msg = "free consultation, then:"
    # end
    "#{lawyer.free_consultation_duration} minutes free"
  end

  def start_or_schedule_button(lawyer)
    if lawyer.is_online? && !lawyer.is_busy
      if logged_in?
        link_to "start video consultation", user_chat_session_path(lawyer), :title => "Start Video Consultation", :class => 'button gray'
      else
        link_to "start video consultation", new_user_path(ut: 0, notice: true), :title => "Start Video Consultation", :class => 'button gray'
      end
    else
      if logged_in?
        if lawyer.phone.present?
          if current_user.stripe_customer_token.present?
            link_to "start phone consultation", phonecall_path(:id => lawyer.id), :id => "start_phone_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "button gray"
          else
            link_to "start phone consultation", "#paid_schedule_session", :id => "start_phone_session_button", :data => { :attorneyid => lawyer.id, :fcd => lawyer.free_consultation_duration, :lrate => lawyer.rate, :fullname => lawyer.first_name },:class => "dialog-opener button gray"
          end

        else
          link_to "schedule consultation", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "dialog-opener button gray"
        end
      else
        btn_class = lawyer.phone.present? ? 'button gray' : 'button gray'
        link_to lawyer.phone.present? ? 'start phone consultation' : 'schedule consultation', new_user_path(ut: 0, notice: true), :class => btn_class
      end
    end
  end

 def start_phone_consultation(lawyer)
   if logged_in?
    if current_user.stripe_customer_token.present?
      link_to "start phone consultation", phonecall_path(:id => lawyer.id), :id => "start_phone_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "button gray"
    else
      link_to "start phone consultation", "#paid_schedule_session", :id => "start_phone_session_button", :data => { :attorneyid => lawyer.id, :fcd => lawyer.free_consultation_duration, :lrate => lawyer.rate, :fullname => lawyer.first_name },:class => "dialog-opener button gray"
    end
  else
    link_to 'start phone consultation', new_user_path(ut: 0, notice: true), :class => "button gray"
  end
 end
end

