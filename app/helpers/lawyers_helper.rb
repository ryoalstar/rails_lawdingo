module LawyersHelper
  # def selected_offerings_caption
  #   # Offerings
  #   if @offerings.present?
  #     offerings_count  = @offerings.count.to_s
  #     offerings_str = @offerings.count > 1 ? "services" : "service"
  #     offerings_verb = @offerings.count > 1 ? "are" : "is"
  #   else
  #     offerings_count = "no"
  #     offerings_str = "services"
  #     offerings_verb = "are"
  #   end

  #   # State
  #   # Depends on if the request came from the landing page or from
  #   # filter_result ajax function
  #   if params[:select_state].present?
  #     state_id = params[:select_state].to_i
  #   elsif params[:state].present?
  #     state_id = params[:state].to_i
  #   end

  #   if state_id.present? && state_id != 0
  #     state = State.find(state_id)
  #     state = " #{state.name}"
  #   elsif @autoselected_state.present?
  #     state = " #{@autoselected_state.name}"
  #   end

  #   # Check if the practice area is selected for
  #   # filtering offers
  #   if @offerings_practice_area.present?
  #     "There #{offerings_verb} #{offerings_count} <strong>#{@offerings_practice_area.name.downcase}</strong>-related #{state} #{offerings_str} that may be of interest to you.".html_safe
  #   else
  #     "There #{offerings_verb} #{offerings_count} #{state} #{offerings_str} that may be of interest to you."
  #   end
  # end

  # def selected_lawyers_caption
  #   state = ""
  #   area = ""
  #   speciality = ""

  #   # Lawyers count
  #   if @lawyers.present?
  #     lawyers_count = @lawyers.count.to_s
  #     lawyers_str = @lawyers.count > 1 ? "lawyers" : "lawyer"
  #     lawyers_verb = @lawyers.count > 1 ? "are" : "is"
  #   else
  #     lawyers_count = "no"
  #     lawyers_str = "lawyers"
  #     lawyers_verb = "are"
  #   end

  #   if state_id.present? && state_id != 0
  #     state = State.find(state_id)
  #     state = " #{state.name}"
  #   elsif @autoselected_state.present?
  #     state = " #{@autoselected_state.name}"
  #   end

  #   # Practice area
  #   if params[:select_pa].present?
  #     area_id = params[:select_pa].to_i
  #   elsif params[:pa].present?
  #     area_id = params[:pa].to_i
  #   end

  #   if area_id.present? && area_id != 0
  #     area = PracticeArea.find(area_id)
  #     area = " #{area.name.downcase}"
  #   end

  #   # Speciality
  #   if params[:select_sp].present?
  #     speciality_id = params[:select_sp].to_i
  #   elsif params[:sp].present?
  #     speciality_id = params[:sp].to_i
  #   end

  #   if speciality_id.present? && speciality_id != 0
  #     speciality = PracticeArea.find(speciality_id)
  #     speciality = " on #{speciality.name.downcase}"
  #   end

  #   if lawyers_count
  #     "There #{lawyers_verb} #{lawyers_count}#{state}#{area} #{lawyers_str} who can offer you legal advice#{speciality} right now."
  #   end
  # end
  def practice_areas_listing(lawyer)
    areas = lawyer.practice_areas.parent_practice_areas unless lawyer.practice_areas.blank?
    areas_names = areas.map do |area|
      area.name.downcase
    end

    last_area_name = areas_names.pop
    areas_names.empty? ? last_area_name : "#{areas_names.join(', ')} and #{last_area_name}"
  end

  def bar_memberships_listing lawyer, show_title = true
    output = '<div id="div_states_barids">'
    bms_text = ''
    bar_memberships_with_state_present = false
    bms = lawyer.bar_memberships
    if bms.present?
      bms.each do |bm|
        if bm.state
          bar = bm.bar_id? ? "(Bar ID: #{bm.bar_id})" : ""
          bms_text += "<li>#{bm.state.name} #{bar}</li>"
        bar_memberships_with_state_present = true
        end
      end
    end
    output += '<h2>Bar Memberships: </h2>' if show_title
    output += "<ul class='tick bar_list'>#{bms_text}</ul></div>"
    output += "<a href='#bar_membership' id='barids_editor' class='edit_barmembership dialog-opener#{bar_memberships_with_state_present ? '' : ' hidden'}'>Edit</a>"
    output += "<a href='#bar_membership' id='barids_opener' class='dialog-opener blue_button no-inner-shadow#{bar_memberships_with_state_present ? ' hidden' : ''}'>State Bar Membership(s)</a>"
    output.html_safe
  end

  def practice_areas_listing lawyer, show_title = true
    output = '<div id="div_practice_areas">'
    pas_text = ''
    pas = lawyer.practice_areas
    ppas = lawyer.practice_areas.parent_practice_areas
    if ppas.present?
      pas_text = ''
      ppas.each do |pa|
        pas_text += "<li>#{pa.name}"
        sps = pa.specialities
        sps_text = ""

        sps.each{|sp|
          sps_text += pas.include?(sp)? "#{sp.name}, ": ""
        }
        sps_text.chomp!(', ')
        pas_text += (sps_text != '')? "(#{sps_text})</li>": "</li>"
      end
      pas_text.chomp!(", ")
    end
    output += '<h2>Practice Areas: </h2>' if show_title
    output += "<ul class='tick pa_list'>#{pas_text}</ul></div>"
    output += "<a href='#practices' id='practice_areas_editor' class='dialog-opener#{ppas.present? ? '' : ' hidden'}'>Edit</a>"
    output += "<a href='#practices' id='practice_areas_opener' class='dialog-opener blue_button no-inner-shadow#{ppas.present? ? ' hidden' : ''}'>Your Practice Areas</a>"
    output.html_safe
  end

  def free_message lawyer
    return '' unless lawyer.is_a? Lawyer
    lawyer.consultation_free? ? 'Talk for free' : "#{lawyer.free_consultation_duration} minutes free"
  end

  def free_message_then lawyer
    lawyer.consultation_free? ? '' : content_tag(:p, "then #{number_to_currency (lawyer.rate_for_minutes(6) + AppParameter.service_charge_value)} per 6 mins", class: "small")
  end

  def start_or_schedule_button(lawyer)
    if lawyer.is_online && !lawyer.is_busy
      if logged_in? && current_user.is_lawyer?
        link_to "Chat now by video conference", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
      elsif logged_in?
        link_to "Chat now by video conference", user_chat_session_path(lawyer), :class => ''
      else
        link_to "Chat now by video conference", new_client_path(notice: true, return_path: user_chat_session_path(lawyer)), :class => ''
      end
    else
      if lawyer.is_available_by_phone?
        if logged_in? && current_user.is_lawyer?
          link_to "Chat now by phone", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
        elsif logged_in?
          if current_user.stripe_customer_token.present?
            link_to "Chat now by phone", phonecall_path(:id => lawyer.id), :id => "start_phone_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => ""
          else
          # link_to "start phone consultation", "#paid_schedule_session", :id => "start_phone_session_button", :data => { :lawyerid => lawyer.id, :fcd => lawyer.free_consultation_duration, :lrate => lawyer.rate, :fullname => lawyer.first_name },:class => "dialog-opener "
            link_to "Chat now by phone", call_payment_lawyer_path(lawyer.id), :id => "start_phone_session_button", :class => ""
          end
        else
          link_to 'Start phone consultation', new_client_path(notice: true, return_path: phonecall_path(:id => lawyer.id), lawyer_path: lawyer.id), :class => ''
        end
      else
        if lawyer.daily_hours.present?
          if logged_in? && current_user.is_lawyer?
            link_to "Book appointment", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
          else
            link_to "Book appointment", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "dialog-opener "
          end
        else
          start_or_schedule_button_text(lawyer)
        end
      end

    end
  end
=begin
def ask_question_button(lawyer)
if logged_in?
link_to "", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "dialog-opener "
else
link_to "", new_client_path(question_notice: true, return_path: lawyer_path(lawyer, slug: lawyer.slug), lawyer_path: lawyer.id), :class => ''
end
end

def ask_question_button_text(lawyer)
if logged_in?
link_to "Ask a question", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "dialog-opener "
else
link_to "Ask a question", new_client_path(question_notice: true, return_path: lawyer_path(lawyer, slug: lawyer.slug), lawyer_path: lawyer.id), :class => ''
end
end

def schedule_consultation_button(lawyer)
if logged_in?
link_to "", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "dialog-opener "
else
link_to "", new_client_path(notice: true, appointment_with:lawyer.id,  return_path: lawyer_path(lawyer, slug: lawyer.slug)), :class => ''
end
end
=end

  def schedule_consultation_button_text(lawyer)
    if logged_in? && current_user.is_lawyer?
      link_to "Book appointment", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
    elsif logged_in?
      link_to "Book appointment", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "appt-select"
    else
      link_to "Book appointment", new_client_path(appointment_with:lawyer.id,  return_path: lawyer_path(lawyer, slug: lawyer.slug)), :class => ''
    end
  end

=begin
def start_or_schedule_button_text(lawyer)
if logged_in?
link_to "Send a note or ask a question", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "dialog-opener "
else
link_to "Send a note or ask a question", new_client_path(notice: true, return_path: lawyer_path(lawyer, slug: lawyer.slug), lawyer_path: lawyer.id), :class => ''
end
end

#Note/Question buttons
def start_or_schedule_button_text_profile(lawyer)
if logged_in?
link_to "", "#schedule_session", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "dialog-opener "
else
link_to "", new_client_path(notice: true, return_path: lawyer_path(lawyer, slug: lawyer.slug), lawyer_path: lawyer.id), :class => ''
end
end
=end
  def schedule_consultation_button(lawyer)
    if logged_in? && current_user.is_lawyer?
      link_to "", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
    elsif logged_in?
      link_to "", "#", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "appt-select"
    else
      link_to "", new_client_path(appointment_with:lawyer.id,  return_path: lawyer_path(lawyer, slug: lawyer.slug)), :class => ''
    end
  end

  def schedule_consultation_button_profile_text(lawyer)
    if logged_in? && current_user.is_lawyer?
      link_to "Book appointment", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
    elsif logged_in?
      link_to "Book appointment", "#", :id => "schedule_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "appt-select"
    else
      link_to "Book appointment", new_client_path(appointment_with:lawyer.id,  return_path: lawyer_path(lawyer, slug: lawyer.slug)), :class => ''
    end
  end

  def start_video_button(lawyer)
    if lawyer.is_online && !lawyer.is_busy
      if logged_in? && current_user.is_lawyer?
        link_to "Chat now by video conference", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
      elsif logged_in?
        link_to "Chat now by video conference", user_chat_session_path(lawyer), :title => "Chat now by video conference", :class => "state-and-practice-area-validation-dialog-opener"
      else
        link_to "Chat now by video conference", new_client_path(notice: true, return_path: user_chat_session_path(lawyer)), :title => "Chat now by video conference", :class => "state-and-practice-area-validation-dialog-opener"
      end
    end
  end

  def start_or_video_button_p(lawyer)
    if lawyer.is_online && !lawyer.is_busy
      if logged_in? && current_user.is_lawyer?
        link_to "", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
      elsif logged_in?
        link_to "", user_chat_session_path(lawyer), :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "state-and-practice-area-validation-dialog-opener"
      else
        link_to "", new_client_path(notice: true, return_path: user_chat_session_path(lawyer), lawyer_path: lawyer.id), :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "state-and-practice-area-validation-dialog-opener"
      end
    end
  end

  def start_or_video_button_text(lawyer)
    if lawyer.is_online && !lawyer.is_busy
      if logged_in? && current_user.is_lawyer?
        link_to "Start a video consultation", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
      elsif logged_in?
        link_to "Start a video consultation", user_chat_session_path(lawyer), :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "state-and-practice-area-validation-dialog-opener"
      else
        link_to "Start a video consultation", new_client_path(notice: true, return_path: user_chat_session_path(lawyer), lawyer_path: lawyer.id), :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "state-and-practice-area-validation-dialog-opener"
      end
    end
  end

  def start_or_video_button_profile(lawyer)
    if lawyer.is_online && !lawyer.is_busy
      if logged_in? && current_user.is_lawyer?
        link_to "Start free video consultation", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
      elsif logged_in?
        link_to "Start free video consultation", user_chat_session_path(lawyer), :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "state-and-practice-area-validation-dialog-opener"
      else
        link_to "Start free video consultation", new_client_path(notice: true, return_path: user_chat_session_path(lawyer), lawyer_path: lawyer.id), :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "state-and-practice-area-validation-dialog-opener"
      end
    end
  end

  def start_phone_consultation(lawyer)
    if logged_in? && current_user.is_lawyer?
      link_to "Start phone consultation", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
    elsif logged_in?
      link_to "Start phone consultation", phonecall_path(:id => lawyer.id), :id => "start_phone_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "state-and-practice-area-validation-dialog-opener"
    else
      link_to 'Start phone consultation', new_client_path(notice: true, return_path: phonecall_path(:id => lawyer.id), lawyer_path: lawyer.id), :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "state-and-practice-area-validation-dialog-opener"
    end
  end

  def start_phone_consultation_p(lawyer)
    if logged_in? && current_user.is_lawyer?
      link_to "", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
    elsif logged_in?
      link_to "", phonecall_path(:id => lawyer.id), :id => "start_phone_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "state-and-practice-area-validation-dialog-opener"
    else
      link_to "", new_client_path(notice: true, return_path: phonecall_path(:id => lawyer.id), lawyer_path: lawyer.id), :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "state-and-practice-area-validation-dialog-opener"
    end
  end

  def start_phone_consultation_profile(lawyer)
    if logged_in? && current_user.is_lawyer?
      link_to "Start free phone consultation", "javascript:void(0)", :class => :only_for_client, :title => "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
    elsif logged_in?
      link_to "Start free phone consultation", phonecall_path(:id => lawyer.id), :id => "start_phone_session_button", :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "state-and-practice-area-validation-dialog-opener"
    else
      link_to "Start free phone consultation", new_client_path(notice: true, return_path: phonecall_path(:id => lawyer.id), lawyer_path: lawyer.id), :data => { :l_id => lawyer.id, :fullname => lawyer.first_name }, :class => "state-and-practice-area-validation-dialog-opener"
    end
  end

  def start_phone_consultation_path(lawyer)
    if logged_in? && current_user.is_lawyer?
      ''
    elsif logged_in?
      phonecall_path(:id=>lawyer.id)
    else
      new_client_path(:notice => true, :return_path => phonecall_path(:id=>lawyer.id), :lawyer_path=>lawyer.id)
    end
  end

  def status_message(lawyer)
    if lawyer.is_online
      "online now"
    elsif lawyer.is_available_by_phone?
      "available by phone now"
    end
  end

  def years_practicing_law(lawyer)
    if lawyer.license_year.present? && lawyer.license_year != 0
      Time.now.year.to_i - lawyer.license_year.to_i
    end
  end

  def selected_lawyers_caption
    is_are = @search.total == 1 ? "is " : "are "
    ct = @search.total == 0 ? "no " : "#{@search.total} "
    lawyers_string = @search.total == 1 ? "lawyer" : "lawyers"

    return "There #{is_are}#{ct}#{selected_state_string}" +
    "#{parent_practice_area_string}#{lawyers_string} " +
    "who can offer you legal advice #{child_practice_area_string}" +
    "right now."
  end

  def selected_offerings_caption
    is_are = @offerings.count == 1 ? "is" : "are"
    ct = @offerings.count == 0 ? "no" : @offerings.count.to_s
    service_string = @offerings.count == 1 ? "service" : "services"
    parent_practice_area_string = params[:practice_area] if !!params[:practice_area] && params[:practice_area]!='All'
    return "There #{is_are} #{ct}#{selected_state_string}" +
    " #{parent_practice_area_string} #{service_string} " +
    "that may be of interest to you."
  end

  def selected_state_string
    @selected_state.present? ? "#{@selected_state.name} " : ""
  end

  def parent_practice_area_string
    if params[:practice_area].present? && params[:practice_area] != "All"
      return "#{params[:practice_area]} ".downcase
    else
      return ""
    end
  end

  def child_practice_area_string
    return "" unless @selected_practice_area.present?
    return "" unless @selected_practice_area.parent_name.present?
    return "on #{@selected_practice_area.name.downcase} "
  end

  def tooltips lawyer
    output = ''
    if lawyer.is_online
      output << '<div class="video_chat online tooltip dominant"> Start video consultation</div>'
    else
      output << '<div class="video_chat offline tooltip"> Not available by video</div>'
    end
    if lawyer.is_available_by_phone?
      output << "<div class='voice_chat online tooltip#{lawyer.is_online ? '' : ' dominant'}'> Start phone consultation</div>"
    else
      output << '<div class="voice_chat offline tooltip"> Not available by phone</div>'
    end
    if lawyer.daily_hours.present?
      output << "<div class='text_chat online tooltip#{lawyer.is_online || lawyer.is_available_by_phone? ? '' : ' dominant'}'> Book appointment</div>"
    else
      output << '<div class="text_chat offline tooltip">No appointments available</div>'
    end
    output << "<div class='note_chat tooltip#{lawyer.is_online || lawyer.is_available_by_phone? || lawyer.daily_hours.present? ? '' : ' dominant'}''> Ask a question</div>"
    output.html_safe
  end

  def pluralize_without_count(count, noun, text = nil)
    if count != 0
      count == 1 ? "#{noun}#{text}" : "#{noun.pluralize}#{text}"
    end
  end

  def lawyer_rate(lawyer)
    number_to_currency("#{lawyer.rate + AppParameter.service_charge_value}") + "/minute"
  end
  
  def yelp_review_posted_by(review)
    user_id = review["user"]["id"]
    user_name = review["user"]["name"]

    link_to_user = link_to user_name, "http://www.yelp.com/user_details?userid=#{user_id}", :rel => :nofollow
    link_to_yelp = link_to "Yelp.com", "http://www.yelp.com", :rel => :nofollow

    "Posted by #{link_to_user} on #{link_to_yelp}".html_safe
  end

  def yelp_review_excerpt(review, lawyer)
    "#{review["excerpt"]} #{link_to "read more", "http://www.yelp.com/biz/#{lawyer.yelp_business_id}#hrid:#{review["id"]}", :rel => :nofollow}".html_safe
  end
end

