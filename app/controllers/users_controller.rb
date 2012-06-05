class UsersController < ApplicationController

  before_filter :authenticate, :except =>[:index, :new, :create, :home, :register_for_videochat, :find_remote_user_for_videochat, :welcome_lawyer, :update_online_status, :has_payment_info, :chat_session, :landing_page, :search]
  before_filter :ensure_self_account, :only =>[:edit, :update]
  before_filter :ensure_admin_login, :only =>[:update_parameter]
  before_filter :current_user_home, :only => [:landing_page]
  #before_filter :check_payment_info, :only => [:start_phone_call]

  #REMINDER: uncomment only in production
  #before_filter :force_ssl, :only => ['payment_info']
  #before_filter :remove_ssl, :only => ['home']

  def index
    @tab  = params[:t] ? params[:t] : User::SESSION_TAB
    if User::PAYMENT_TAB == @tab
      #@card_detail = current_user.card_detail || CardDetail.new
    elsif User::SESSION_TAB == @tab
      @conversations = current_user.corresponding_user.conversations
    end
  end

  def home
    # if current_user and current_user.is_lawyer?
    #   redirect_to users_path(:t=>'l')
    # end
    #return render :json =>current_user

    @question = Question.new

    @practice_areas = PracticeArea.parent_practice_areas

    @lawyers = Lawyer.approved_lawyers
    # add some includes
    @lawyers = @lawyers.includes(
      [:practice_areas, {:bar_memberships => :state}, :reviews]
    )
    @states = State.with_approved_lawyers
    query = params[:search_query]
    
    service_type = (params[:service_type] || "")
    @service_type = service_type.downcase || ""
    
    
    if @service_type == "legal-services"
       @search = Offering.build_search(query)
    else
       @search = Lawyer.build_search(query) 
    end
    add_service_type_scope
    add_state_scope
    add_practice_area_scope
    add_free_time_scope
    add_lawyer_rating_scope
    add_hourly_rate_scope
    add_school_rank_scope
    
    
    @search.execute
        
    if @service_type == "legal-services"
      @offerings = @search.results
    else
      @lawyers = @search.results  
    end
    
    # we try to auto-detect the state if possible
    if self.get_state_name.blank? && request.location.present? && request.location.state_code.present?
      if state = State.find_by_abbreviation(request.location.state_code)
        @state_name = state.name
      end
    end

    respond_to do |format|
      format.html{render}
      format.js{render}
    end
  end

  def landing_page
    @tagline = AppParameter.find(2).value || "Free legal advice."
    @subtext = AppParameter.service_homepage_subtext
  end

  def show
    begin
      @user = User.find params[:id]
      @user = Lawyer.find(@user.id) if @user.is_lawyer?
#      @tab  = params[:t] ? params[:t] : User::ACCOUNT_TAB
      @tab  = params[:t] ? params[:t] : User::SESSION_TAB
      if User::PAYMENT_TAB == @tab
        if !request.ssl?
          redirect_to :protocol => 'https', :t => 'm'
        end
      elsif User::ACCOUNT_TAB == @tab && @user.is_lawyer?
        @filled_states = @user.states
        unless @filled_states.blank?
          filled_state_ids = []
          @filled_states.each{|state| filled_state_ids << state.id}
          @states = State.where('id not in (?)', filled_state_ids).all
        else
          @states = State.all
        end
        @states.count.times {@user.bar_memberships.build}
      elsif User::SESSION_TAB == @tab
        @conversations = current_user.corresponding_user.conversations
      end
    rescue
      path  = current_user ? user_path(current_user) : root_path
      redirect_to path, :notice =>"No user found!" and return
    end
    if @user.is_admin? && current_user.id != @user.id
      redirect_to root_path
    end
  end

  def new
    if params[:return_path]
      session[:return_to] = params[:return_path]
    end
    redirect_to root_path and return if current_user
    user_type  = params[:ut] || '1'
    if user_type == '0'
      @user       = User.new(:user_type => User::CLIENT_TYPE  )
    else
      @user       = Lawyer.new(:user_type => User::LAWYER_TYPE )
      @states = State.all
      @states.count.times {@user.bar_memberships.build}
    end
  end

  def create
    redirect_to root_path and return if current_user
    user_type = params[:user_type]
    @user     = user_type == User::LAWYER_TYPE ? Lawyer.new(params[:lawyer]) : User.new(params[:user])
    @user.user_type = user_type

    if @user.user_type == User::LAWYER_TYPE
      # per minute rate from hourly
      @user.rate = (params[:lawyer][:rate].to_f / 60.to_f).round(2)
    end

    if @user.save

      if @user.user_type == User::LAWYER_TYPE
        unless params[:practice_areas].blank?
          practice_areas = params[:practice_areas]
          practice_areas.each{|pid|
            ExpertArea.create(:lawyer_id => @user.id, :practice_area_id => pid)
          }
        end
        UserMailer.notify_lawyer_application(@user).deliver
        #redirect_to welcome_path and return
        login_in_user(@user)
        redirect_to user_offerings_path(@user, :ft => true) and return
      elsif @user.is_client?

        UserMailer.notify_client_signup(@user).deliver
        session[:user_id] = @user.id
        
        # If there is a pending question
        if session[:question_id].present?
          send_pending_question(session[:question_id], @user) and return
        end
        
        return_path = ""
        if session[:return_to]
          return_path = session[:return_to]
          session[:return_to] = nil
        else
          return_path = lawyers_path
        end
        redirect_to return_path and return
      else
        redirect_to root_path and return
      end
    else

      if @user.user_type == User::LAWYER_TYPE
        err_msg = ''
        errors = @user.errors
        if errors.size > 0
          err_msg += '<div class="error_explanation"><h4 class="error">Please fix the following errors:</h4><ul><class="errors">'
          errors.full_messages.each do |error|
            err_msg += "<li>#{error}</li>"
          end
          err_msg += '</ul></div>'
          flash[:error] = err_msg
        end
        redirect_to :action => :new, :ut => 1 and return
      end

      #@states = State.all

      render :action =>:new, :ut =>user_type == User::LAWYER_TYPE ? '1' : '0'
    end
  end

  def welcome_lawyer
  end

  def edit
    begin
      @user = User.find(params[:id])
      if @user.is_lawyer?
        @user = Lawyer.find(@user.id)
        @filled_states = @user.states
        unless @filled_states.blank?
          filled_state_ids = []
          @filled_states.each{|state| filled_state_ids << state.id}
          @states = State.where('id not in (?)', filled_state_ids).all
        else
          @states = State.all
        end
        @states.count.times {@user.bar_memberships.build}
      end
    rescue
      redirect_to root_path, :notice =>"Couldn't find any record"
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.is_lawyer?
      @user  = Lawyer.find(@user.id)
      status = @user.update_attributes(params[:lawyer])
      @user.update_attribute :school_id, params[:lawyer][:school_id]
      @user.corresponding_user.practice_areas.delete_all
      unless params[:practice_areas].blank?
        practice_areas = params[:practice_areas]
        practice_areas.each{|pid|
          pa = PracticeArea.find(pid)
          if !pa.main_area.nil? && !practice_areas.include?(pa.main_area.id.to_s)
            practice_areas << pa.main_area.id.to_s
          end
        }
        practice_areas.uniq!
        practice_areas.each{|pid|
          ExpertArea.create(:lawyer_id => @user.id, :practice_area_id => pid)
        }
      end
    else
      status = @user.update_attributes(params[:user])
    end
    unless params[:return_url].blank?
      @msg = status ? 'Account Updated Successfully' : nil
      #render :action =>:show, :t => User::ACCOUNT_TAB and return
      redirect_to params[:return_url], :notice => @msg and return
    end
    if status
      redirect_to root_path, :notice =>"Account Updated Successfully"
    else
      render :action =>:edit
    end
  end

  def image_upload
    begin
      user = User.find(params[:user_id])
    rescue
      user = nil
    end
    if user
      user.update_attributes(params[:user])
      notice = 'Image uploaded successfully'
    else
      notice = 'No Account Found!'
    end
    redirect_to user_path(user), :notice =>notice
  end

  def payment_info
#    redirect_to root_path and return if current_user.card_detail
    token = params[:stripe_card_token]
    if request.method == "POST"
      customer = Stripe::Customer.create(
        :card => token,
        :description => current_user.email
      )
      if current_user.stripe_customer_token.present?
        curl_cmd = "curl https://api.stripe.com/v1/customers/#{current_user.stripe_customer_token} \
              -u #{Stripe.api_key}: -X DELETE"
        system curl_cmd
      end
      if customer && current_user.save_stripe_customer_id(customer.id)
        redirect_to user_path(current_user), :notice => 'Thank you for completing your payment info' and return
      else
        redirect_to root_path and return
      end
    else
      #@card_detail = CardDetail.new
    end
  end

  def update_payment_info
   @status = false
   @phone_call_payment_status = false
   token = params[:stripe_card_token]
   customer = Stripe::Customer.create(
        :card => token,
        :description => current_user.email
      )
   if current_user.stripe_customer_token.present?
    curl_cmd = "curl https://api.stripe.com/v1/customers/#{current_user.stripe_customer_token} \
              -u #{Stripe.api_key}: -X DELETE"
    system curl_cmd
   end
   if customer && current_user.save_stripe_customer_id(customer.id)
    @status = true
   end

   unless params[:attorney_id].blank?
     #render :js => "window.location = '#{phonecall_path(:id => params[:attorney_id])}'" and return
     @phone_call_payment_status = true
   else
    @err_msg = ''
    errors = current_user.errors
    if errors.size > 0
      @err_msg += '<div class="error_explanation"><h4 class="error">Please fix the following errors:</h4><ul><class="errors">'
      errors.full_messages.each do |error|
        @err_msg += "<li>#{error}</li>"
    end
      @err_msg += '</ul></div>'
    end
   end

  end

  def has_payment_info
    @user = User.find(params[:user_id])
    status = @user.stripe_customer_token.present? ? '1' : '0'
    render :text => status, :layout => false
  end

  def start_phone_call
    @lawyer = User.find(params[:id]) if params[:id].present?
  end

  def create_phone_call
    unless params[:client_number].blank?
      @lawyer = Lawyer.find(params[:lawyer_id])
      @client = Twilio::REST::Client.new 'ACc97434a4563144d08e48cabd9ee4c02a', '3406637812b250f4c93773f0ec3e4c6b'
     # make a new outgoing call
     begin
      @call = @client.account.calls.create(
        :From => TWILIO_FROM,
        :To => @lawyer.phone,
        :Url => twilio_voice_url(:cn => params[:client_number], :free_duration => @lawyer.free_consultation_duration, :lrate => @lawyer.rate),
        :FallBackUrl => twilio_fallback_url,
        :StatusCallback => twilio_callback_url,
      )
      Call.create(:client_id => current_user.id, :from => params[:client_number], :to =>@lawyer.phone, :lawyer_id => @lawyer.id, :sid => @call.sid, :status => 'dialing', :start_date => Time.now)
     rescue
       redirect_to phonecall_path(:id=>params[:lawyer_id], number: params[:client_number]), :notice => "Error: making a call"
     end
    else
      redirect_to phonecall_path(:id=>params[:lawyer_id], number: params[:client_number]), :notice => "Please enter you phone number"
    end
  end

  def end_phone_call
    @client = Twilio::REST::Client.new 'ACc97434a4563144d08e48cabd9ee4c02a', '3406637812b250f4c93773f0ec3e4c6b'
    @call = @client.account.calls.get(params[:call_id])
    @call.hangup
    render :text => "", :layout => false
  end

  def check_call_status
    @call = Call.find_by_sid(params[:call_id])
    if @call.status == 'dialing' || @call.status == 'connected' || @call.status == 'billed'
    elsif @call.status == 'completed'
      call_conversation = Conversation.find(@call.conversation_id)
      render :js => "window.location = '#{conversation_summary_path(call_conversation, :call_type =>'phonecall')}'", :notice => "Your call is completed"
      return
    else
      render :js => "window.location = '#{root_path}'"
      return
    end
  end

  def update_call_status
    @call = Call.find_by_sid(params[:call_id])
    if params[:sb] && params[:sb].to_i == 1
      if current_user.stripe_customer_token.present?
       @call.update_attributes(:billing_start_time => Time.now, :status => 'billed')
      else
       @client = Twilio::REST::Client.new 'ACc97434a4563144d08e48cabd9ee4c02a', '3406637812b250f4c93773f0ec3e4c6b'
       @call = @client.account.calls.get(params[:call_id])
       @call.hangup
      end
    end
    render :text => "", :layout =>false
  end

  def onlinestatus
    begin
      user = User.find params[:user_id]
    rescue
    end
    if user
      render :text => ((!user.is_busy? && user.is_online?) ? '1' : '0') and return
    else
      render :text =>'0' and return
    end
  end

  # start chat session with chosen lawyer
  # for logged in user
  def chat_session
    #redirect_to card_detail_path and return unless current_user.card_detail
    begin
      @lawyer = Lawyer.find params[:user_id]
    rescue
      @lawyer = nil
    end
  end

  def session_history
    begin
      @user = User.find params[:user_id]
    rescue
      redirect_to root_path, :notice =>"No Account Found!"
    end
  end

  def update_parameter
    begin
      pobj    = AppParameter.find params[:id]
    rescue
      pobj    = nil
    end
    # pvalue = params[:value]
    # pvalue = pvalue.blank? ? pobj.value : pvalue.strip

    pvalue = ""
    pvalue = params[:value].to_s if params[:value].present?

    if pobj
      pobj.update_attribute(:value, pvalue)
      render :text =>'Successfully Updated!'
    else
      render :text =>'Update failed!'
    end
  end

  def send_email_to_lawyer


    if !current_user.nil?

      begin
      #render :text => 'in current user block1', :layout => false
        @lawyer = User.find(params[:l2])
        msg = params[:email_msg]
        UserMailer.schedule_session_email(current_user, @lawyer.email, msg).deliver
      rescue
      end
      render :text => '1', :layout => false
    else
      render :text => '0', :layout => false
    end
  end

  def update_busy_status
    user = User.find(params[:id])
    bool = params[:busy].to_i == 1 ? true : false
    user.update_attribute(:is_busy, bool)
    render :text => "true", :layout => false
  end

  def update_online_status
    if current_user && current_user.is_lawyer?
      current_user.update_attribute(:last_online, DateTime.now)
      render :text => "true", :layout =>false
    else
      render :text => "false", :laout =>false
    end
  end

  def register_for_videochat
    u_id = params[:username] if params[:username]
    peer_id = params[:identity] if params[:identity]
    @user = User.find(u_id)
    @user.peer_id = peer_id
    if @user.save
      render :file=>"users/success.xml", :content_type => 'application/xml', :layout => false
    else
      render :file=>"users/failure.xml", :content_type => 'application/xml', :layout => false
    end
  end

  def find_remote_user_for_videochat
    remote_user_id = params[:friends] if params[:friends]
    begin
      @user = User.find(remote_user_id)
      if @user.peer_id != '0' && @user.is_online? && !@user.is_busy?
        render :file=>"users/remote_user.xml", :content_type => 'application/xml', :layout => false
      else
        render :file=>"users/no_remote_user.xml", :content_type => 'application/xml', :layout => false
      end
    rescue
      render :file=>"users/failure.xml", :content_type => 'application/xml', :layout => false
    end
  end


  private

  def current_user_home
    if current_user
      if current_user.is_lawyer?
        redirect_to users_path(:t=>'l')
      else
        redirect_to lawyers_path
      end
    end
  end

  def ensure_self_account
    return false unless logged_in?
    begin
      @user = User.find params[:id]
    rescue
      redirect_to root_path, :notice =>"No User Found!" and return
    end

    if not (@user.id == current_user.id or logged_in_admin?)
      redirect_to root_path, :notice =>"No Authorization!" and return
    end
  end

  def ensure_admin_login
    return false unless logged_in?
    unless current_user.is_admin?
      redirect_to root_path, :notice =>"No Authorization!" and return
    end
  end

  def force_ssl
    if !request.ssl?
      redirect_to :protocol => 'https'
    end
  end

  def remove_ssl
    if request.ssl?
      redirect_to :protocol => 'http'
    end
  end

  # Backed up home page
  def search

  end

  def check_payment_info
    unless current_user.stripe_customer_token.present?
     redirect_to call_payment_path(params[:id]) and return
    end
  end

  protected


  # helper method to add the service_type
  # scope to the main search
  def add_service_type_scope
    # handle the type of service offered
    service_type = (params[:service_type] || "")
    @service_type = service_type.downcase
    
    # legal services
    if @service_type == "legal-services"
      # @lawyers = @lawyers.offers_legal_services
      @offerings = Offering.find(:all, conditions: { user_id: @lawyers.offers_legal_services.map(&:id) })
      @search.build do
        fulltext params[:search_query]
      end
    # default is legal advice
    else
      @lawyers = @lawyers.offers_legal_advice
    end
  end

  # helper method to add the state scope to the
  # main search
  # add state_scope_for_search__SOLR
  def add_state_scope
    # store selected state for the view
    @selected_state = State.name_like(self.get_state_name).first
    state_name = @selected_state.name if !!@selected_state 
    if @selected_state.present? 
      @search.build do
        fulltext state_name
      end
    end
   end
  
  def add_free_time_scope
    @free_time_val = params[:freetimeval].to_i if !!params[:freetimeval]
    free_time_val_s = @free_time_val
    free_time_val_e = 90
    if @free_time_val.present?
       @search.build do
         with :free_consultation_duration, (free_time_val_s)..(free_time_val_e)
       end
    end
  end
  
  def add_lawyer_rating_scope
    @lawyer_rating = params[:ratingval].to_i if !!params[:ratingval]
    rating_start = @lawyer_rating
    rating_end = 90
    if @lawyer_rating.present?
       @search.build do
         with :lawyer_star_rating, (rating_start)..(rating_end)
       end
    end
  end
  
  
  def add_hourly_rate_scope
    @hourly_start = params[:hourlyratestart].to_i if !!params[:hourlyratestart]
    @hourly_end = params[:hourlyrateend].to_i if !!params[:hourlyrateend]
  
    hourly_start = @hourly_start
    hourly_end = @hourly_end
    if hourly_start==hourly_end
      if hourly_start == 0
        hourly_end=2
      end
      if hourly_start == 6
        hourly_end=99
      end
    end
        
    if @hourly_start.present? && @hourly_end.present?
       @search.build do
         with :rate, (hourly_start-AppParameter.service_charge_value)..(hourly_end-AppParameter.service_charge_value)
       end
    end
  end
  
  
  def add_school_rank_scope
    @school_rank = params[:schoolrating].to_i if !!params[:schoolrating]
  
    rank_start = @school_rank
    rank_end = 4
    
    if @school_rank.present?
       @search.build do
         with :school_rank, (rank_start)..(rank_end)
       end
    end
  end
  
  
  

  # helper method to add the practice area scope to the
  # main search
  # add practic_area_scope_for_search__SOLR
  def add_practice_area_scope 
    # if we have a practice area
    if params[:practice_area].present?
      scope = PracticeArea.name_like(params[:practice_area])
      area_name = scope.first.name if scope.first
        @search.build do
          fulltext area_name
        end
    end
  end
  
 

  # gives us the state name provided in the params
  def get_state_name
    # take California-lawyers and transform to California
    state_name = (params[:state] || "").gsub(/\-lawyers?$/,'')
    return state_name.gsub(/\-/,' ')
  end

end

# Obtain lawyers according to sent GET params
    # state_id = params[:select_state].to_i
    # pa_id = params[:select_pa].to_i
    # sp_id = params[:select_sp].to_i
    # @lawyers = []
    # @state_lawyers = []

    # request.location.state_code.present?

    # if state_id == 0
    #   if request.location.state_code.present?
    #     autoselected_state = State.find_by_abbreviation(request.location.state_code)
    #     if autoselected_state.present?
    #       @state_lawyers = State.find_by_abbreviation(request.location.state_code).lawyers.approved_lawyers
    #     else
    #       @state_lawyers = Lawyer.approved_lawyers
    #     end
    #   else
    #     @state_lawyers = Lawyer.approved_lawyers
    #   end
    # else
    #   @state_lawyers = State.find(state_id).lawyers.approved_lawyers
    # end
    # if pa_id == 0
    #   @lawyers = @state_lawyers
    # else
    #   if sp_id == 0
    #     @selected_practice_area = "general #{PracticeArea.find(pa_id).name.downcase}"
    #     @pa_lawyers = PracticeArea.find(pa_id).lawyers.approved_lawyers
    #   else
    #     @selected_practice_area = PracticeArea.find(sp_id).name.downcase
    #     @pa_lawyers = PracticeArea.find(sp_id).lawyers.approved_lawyers
    #   end
    #   @lawyers = @state_lawyers & @pa_lawyers
    # end

    # # Filtering params from the next home page form
    # state_id = params[:select_state].to_i
    # pa_id = params[:select_pa].to_i
    # sp_id = params[:select_sp].to_i

    # if state_id.present? and state_id.to_i != 0
    #   selected_state = State.find(state_id)
    #   @selected_state_str = [selected_state.name, selected_state.id]
    # else
    #   # Selecting user's state
    #   if request.location.state_code.present?
    #     selected_state = State.find_by_abbreviation(request.location.state_code)
    #     @selected_state_str = [selected_state.name, selected_state.id] if selected_state
    #     @autoselected_state = selected_state
    #   end
    # end

    # if pa_id.present? and pa_id != 0
    #   selected_pa = PracticeArea.find(pa_id)
    #   @selected_pa_str = [selected_pa.name, selected_pa.id]

    #   # Obtaining specialities of this practice area
    #   if sp_id.present? and sp_id != 0
    #     selected_sp = selected_pa.specialities.find_by_id(sp_id)
    #     @selected_sp_str = [selected_sp.name, selected_sp.id]
    #   else
    #     @selected_sp_str = ["General #{selected_pa.name}", 0]
    #   end

    #   # Making an array of specialities
    #   # to populize the select field
    #   @selected_pa_specialities_str = []
    #   @selected_pa_specialities_str << ["General #{selected_pa.name}", 0]
    #   selected_pa.specialities.each do |spec|
    #     @selected_pa_specialities_str << [spec.name, spec.id]
    #   end
    # end

