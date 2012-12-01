class UsersController < ApplicationController
  #include ActionView::Helpers::UrlHelper

  before_filter :authenticate, :except => [:detect_state ,:index, :new, :create, :home, :register_for_videochat, :find_remote_user_for_videochat, :welcome_lawyer, :update_online_status, :has_payment_info, :landing_page, :search, :learnmore, :create_lawyer_request]
  before_filter :ensure_self_account, :only => [:edit, :update]
  before_filter :ensure_admin_login, :only => [:update_parameter]
  before_filter :current_user_home, :only => [:landing_page]
  before_filter :auto_detect_state, :only => [:landing_page, :home]
  before_filter :only_client, :only => [:start_phone_call, :create_phone_call], :if => :logged_in?
  #before_filter :check_payment_info, :only => [:start_phone_call]

  def index
    @tab  = params[:t] ? params[:t] : User::SESSION_TAB
    if User::PAYMENT_TAB == @tab
      #@card_detail = current_user.card_detail || CardDetail.new
    elsif User::SESSION_TAB == @tab
      @conversations = current_user.conversations
    end
  end
  


  def home
    # if current_user and current_user.is_lawyer?
    #   redirect_to users_path(:t=>'l')
    # end
    #return render :json =>current_user    
    @question = Question.new
    @subtext = AppParameter.service_homepage_subtext    
    @practice_areas = PracticeArea.parent_practice_areas
    @states = State.with_approved_lawyers
  
    service_type = (params[:service_type] || "")
    @service_type = service_type.downcase || ""
    
    @search_query = params[:search_query]
    if @service_type == "legal-services"
      @search = Offering.build_search(
        @search_query, :page => params[:page]
      )
    else
      @search = Lawyer.build_search(
        @search_query, 
        :page => params[:page],
        :include => [
          :daily_hours,
          :offerings, 
          :practice_areas, 
          :school, 
          :states
        ]
      )
    end

    save_search 
    add_state_scope
    add_practice_area_scope @service_type
    add_free_time_scope
    add_lawyer_rating_scope
    add_hourly_rate_scope
    add_school_rank_scope

    @search.execute

    if @service_type == "legal-services"
      @results = @search.results
      @offerings = @search.results
    else
      @results = @search.results
      @lawyers = LawyerDecorator.decorate(@results)
    end

    respond_to do |format|
      format.html
      format.js
      format.json { render json: {:lawyers => @lawyers.to_a}, status: :ok }
    end
  end

  def detect_state
    # we try to auto-detect the state if possible
    if request.location.present? && request.location.state_code.present? && params[:autodetect].present?
      if (state = State.find_by_abbreviation(request.location.state_code)) and state.lawyers.count
        @state_name = state.name
        @state_abbreviation = state.abbreviation
      end
    end

    render :js => "var detect_state_name = '#{@state_name}', detect_state_abbreviation = '#{@state_abbreviation}';"
  end

  def learnmore
    @tagline = AppParameter.where(id: 2).first.try(:value) || 'Free legal advice.'
    @subtext = AppParameter.service_homepage_subtext
  end

  def landing_page
    @tagline = AppParameter.where(id: 2).first.try(:value) || 'Free legal advice.'
    @subtext = AppParameter.service_homepage_subtext
    @practice_areas = PracticeArea.parent_practice_areas
    @states = State.with_approved_lawyers
    @homepage_images = HomepageImage.all.shuffle
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
        #I know that this is a bad practice, but this invalid records on bar membership are causing a lot of trouble
        @user.bar_memberships.select{|bm| bm.state.nil?}.each do |bm|
          bm.delete
        end
        fill_states
        @states.count.times {@user.bar_memberships.build}
      elsif User::SESSION_TAB == @tab && @user.is_lawyer?
        @conversations = current_user.conversations
      end
      @schools = School.order(:name)
    rescue => e
      Rails.logger.error(e)
      redirect_to root_path, :notice =>"No user found!" and return
    end
    if @user.is_admin? && current_user.id != @user.id
      redirect_to root_path
    end
  end

  def new
    if params[:return_path]
      session[:return_to] = params[:return_path]
    end

    # Empy return_to if user came from homepage
    if request.referer == root_url
      session[:return_to] = nil 
    end

    # if we are already logged in, return to homepage
    if current_user.present?
      return redirect_to(root_path)
    end

    @user = Client.new
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
        Lawyer.reindex
        unless params[:practice_areas].blank?
          practice_areas = params[:practice_areas]
          practice_areas.each{|pid|
            ExpertArea.create(:lawyer_id => @user.id, :practice_area_id => pid)
          }
        end
        UserMailer.notify_lawyer_application(@user).deliver
        #redirect_to welcome_path and return
        login_in_user(@user)
        redirect_to new_stripe_path and return
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
        fill_states
        
        @schools = School.order(:name)
        bar_memb_with_null_states = @user.bar_memberships.select{|bm| bm.state.nil?}.count
        (@states.count - bar_memb_with_null_states).times {
          @user.bar_memberships.build
        }
        
        
      end
    rescue
      redirect_to root_path, :notice =>"Couldn't find any record"
    end
  end

  def account_information
  end

  def update
    @user = User.find(params[:id])
    if @user.is_lawyer?
      @user  = Lawyer.find(@user.id)
      @user.bar_memberships.delete_all
      @schools = School.order(:name)
      status = @user.update_attributes(params[:lawyer])
      @user.update_attribute :school_id, params[:lawyer][:school_id]
      @user.practice_areas.delete_all
      unless params[:practice_areas].blank?
        practice_areas = params[:practice_areas]
        practice_areas.each{|pid|
          pa = PracticeArea.find(pid)
          if !pa.main_area.nil? && !practice_areas.include?(pa.main_area.id.to_s)
            practice_areas.delete pid
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
      #redirect_to root_path, :notice =>"Account Updated Successfully"
      #redirect_to user_account_information_path(@user.id), :notice =>"Account Updated Successfully"
      redirect_to user_account_information_path(@user.id, :t=>'f')
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

  def update_card_details
    token = params[:client][:stripe_card_token]
    if token.present?
      customer = Stripe::Customer.create(
        email: current_user.email,
        card: token
      )

      if customer
        if current_user.stripe_customer_token.present?
          Stripe::Customer.retrieve(current_user.stripe_customer_token).delete
        end

        current_user.save_stripe_customer_id(customer.id)
      end
    end

    if session[:return_path].present?
      stored_return_path = session[:return_path]
      session[:return_path] = nil

      redirect_to stored_return_path
    else
      redirect_to root_path
    end
  rescue Stripe::CardError => exception
    redirect_to :back, :notice => exception.message
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

   unless params[:lawyer_id].blank?
     #render :js => "window.location = '#{phonecall_path(:id => params[:lawyer_id])}'" and return
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
  
  def have_i_payment_info
    render :json => {:result => current_user.stripe_customer_token.present?}, :layout => false, :status => :ok
  end

  def start_phone_call
    @lawyer = Lawyer.find(params[:id]) if params[:id].present?

    redirect_to call_payment_lawyer_path(@lawyer.id, :return_path=>phonecall_path(:id => params[:id]) ) unless current_user.stripe_customer_token.present?
  end

  def create_phone_call
    if params[:client_number].blank?
      redirect_to phonecall_path(id: params[:lawyer_id], notice: "Please enter your phone number.")
    else
      current_user.update_attribute(:phone, params[:client_number]) if current_user.is_client?

      @lawyer = Lawyer.find(params[:lawyer_id])
      @client = Twilio::REST::Client.new(Twilio::ACCOUNT_SID, Twilio::AUTH_TOKEN)

      # Call the client, son
      @call = @client.account.calls.create(
        from: Twilio::FROM,
        to: current_user.phone,
        url: twilio_welcome_url(
          lawyer_rate: @lawyer.rate,
          lawyer_number: @lawyer.phone,
          client_number: current_user.phone,
          duration_for_free: @lawyer.free_consultation_duration
        ),
        fallbackurl: twilio_fallback_url,
        statuscallback: twilio_callback_url
      )

      Call.create do |call|
        call.client_id  = current_user.id
        call.lawyer_id  = @lawyer.id
        call.from       = current_user.phone
        call.to         = @lawyer.phone
        call.sid        = @call.sid
        call.status     = "dialing"
        call.start_date = Time.now
      end
    end
  end

  def check_call_status
    @call = Call.find_by_sid(params[:call_id])

    unless @call.status == 'dialing' || @call.status == 'connected' || @call.status == 'billed'
      render js: "window.location = '#{conversation_summary_path(@call.conversation, call_type: 'phonecall', form: 'review')}'", :notice => "Your call is completed"
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
    @current_user = current_user
    @lawyer = Lawyer.find(params[:user_id])

    unless current_user.stripe_customer_token.present?
      redirect_to call_payment_lawyer_path(@lawyer.id, type: "video-chat")
      return
    end
    
    @from_to_text = @current_user.full_name + ' to ' + @lawyer.full_name
    
    require "yaml"
    config = YAML.load_file("config/tokbox.yml")

    @api_key = config['API_KEY']
    @api_secret = config['SECRET']
    location = config['LOCATION']
    @opentok = OpenTok::OpenTokSDK.new @api_key, @api_secret

    unless @current_user.is_lawyer?
      @lawyer.update_attribute(:call_status,'invite_video_chat')
      conversation_params = {:client_id=>@current_user.id,:lawyer_id=>@lawyer.id,:start_date=>Time.now,:end_date=>Time.now,:consultation_type => "video"}
      @conversation = Conversation.create_conversation(conversation_params)
      @conversation_id = @conversation.id

      session =  @opentok.create_session(location)

      @lawyer.tb_session_id = session.session_id
      @lawyer.save

      @token  = @opentok.generate_token({:session_id => session.session_id})
    else
      @token  = @opentok.generate_token({:session_id => @lawyer.tb_session_id})
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
      @lawyer = User.find(params[:l2])
      msg = params[:email_msg]

      Message.create do |message|
        message.body = msg
        message.client_id = current_user.id
        message.lawyer_id = @lawyer.id
      end

      UserMailer.schedule_session_email(current_user, @lawyer.email, msg).deliver

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
    case params[:op]
    when "login_by_app"
      if user = User.authenticate(params[:email], params[:password])
        render :json=>{:result=>user, :key=>user.hashed_password} and return
      else
        render :json=>{:result=>'null', :key=>user.hashed_password} and return
      end
    when "set_status_by_app"
      if user = User.authenticate(params[:email], params[:password])
        if(params[:is_online]=='true')
          user.update_attribute(:is_online,true);
        end

        if(params[:is_online]=='false')
          user.update_attribute(:is_online,false);
        end

        if(params[:call_status]=='decline')
          user.update_attribute(:call_status,'decline');
        end
        render :json => { :result => true } and return
      else
        render :json => { :result => 'null' } and return 
      end
    when "call"
      lawyer = User.find(params[:lawyer_id])
      if !current_user.is_lawyer?
          if lawyer.call_status!='accept'
            lawyer.update_attribute(:call_status, params[:call_mode].to_s)    
          end
      else
          lawyer.update_attribute(:call_status, params[:call_mode].to_s)
      end
      render :text => "success" and return
    when "get_call_status"
      if current_user && current_user.is_lawyer?
        current_user.update_attribute(:last_online, DateTime.now)
      end
      lawyer = User.find(params[:lawyer_id])
      render :text=>lawyer.call_status and return
    when "set_online_status"
      if current_user && current_user.is_lawyer?
        current_user.update_attribute(:last_online, DateTime.now)
        if(params[:is_online] == 'true')
          current_user.update_attribute(:is_online, true);
        end
        if(params[:is_online] == 'false')
          current_user.update_attribute(:is_online, false);
        end
        render :json => { :result => current_user } and return 
      end
      render :nothing => true and return 
    when "set_phone_status"
      if current_user && current_user.is_lawyer?
        current_user.update_attribute(:last_online, DateTime.now)
        if(params[:is_available_by_phone] == 'true')
          current_user.update_attribute(:is_available_by_phone, true);
        end
        if(params[:is_available_by_phone] == 'false')
          current_user.update_attribute(:is_available_by_phone, false);
        end
        render :json => { :result => current_user } and return 
      end
      render :nothing => true and return 
    when "end_video_chat"
      lawyer = User.find(params[:lawyer_id])
      lawyer.update_attribute(:call_status, "")
      
      conversation = Conversation.find(params[:conversation_id])
      conversation.update_attribute(:end_date,Time.now)
    end
    render :nothing => true and return 
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

  def create_lawyer_request
    request_body = params[:request_body]
    UserMailer.lawyer_request_email(request_body).deliver unless request_body.empty?

    render nothing: true
  end

  private

  def current_user_home
    if current_user
      if current_user.is_lawyer?
        redirect_to user_daily_hours_path(current_user.id)
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
     redirect_to call_payment_lawyer_path(params[:id]) and return
    end
  end

  protected

  # helper method to add the state scope to the
  # main search
  # add state_scope_for_search__SOLR
  def add_state_scope
    # store selected state for the view

    @selected_state = State.find_by_id(params[:state]) if params[:state] && params[:state].numeric?
    @selected_state ||= State.name_like(self.get_state_name).first
    state_id = @selected_state.try(:id)
    @search.build do
      with(:state_ids, [state_id])
    end if state_id
    @state_id = state_id
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
      if hourly_start == 4
        hourly_end=6
      end
      if hourly_start == 2
        hourly_end=4
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
  def add_practice_area_scope service_type
    # if we have a practice area
    if params[:practice_area].present?
      @practice_area = params[:practice_area].numeric? ? PracticeArea.find_by_id(params[:practice_area]) : PracticeArea.name_like(params[:practice_area]).first
      area_id = @practice_area.try(:id)
      @search.build do
        service_type == "legal-services" ? with(:practice_area_id, area_id) : with(:practice_area_ids, [area_id])
      end if area_id
      @area_id = area_id
    end
  end

  # gives us the state name provided in the params
  def get_state_name
    # take California-lawyers and transform to California
    state_name = (params[:state] || "").gsub(/\-lawyers?$/,'')
    return state_name.gsub(/\-/,' ')
  end

  def save_search
    query = params[:search_query].presence
    page = params[:page].presence
    user = current_user.presence
    if query && user
      search = Search.find_or_create_by_query_and_user_id(query, user.id) unless page
    elsif query
      search = Search.find_or_create_by_query_and_user_id(query, nil) unless page
    end
    search.increment!(:count) if search.is_a? Search
  end

  def fill_states     
    @filled_states = @user.states
    unless @filled_states.blank?
      filled_state_ids = []
      @filled_states.each{|state| filled_state_ids << state.id}
      @states = State.where('id not in (?)', filled_state_ids).all
    else
      @states = State.all
    end
  end 

  def redirect_to_last_practice_area_state_select_from_cookie
    if cookies[:practice_area] && cookies[:state]
      path_from_cookie = filtered_path(:service_type => 'Legal-Advice', :state => cookies[:state], :practice_area => cookies[:practice_area])
      if lawyers_path? && !current_path?(path_from_cookie)
        redirect_to(path_from_cookie) and return
      end
    end
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
