class UsersController < ApplicationController

  before_filter :authenticate, :except =>[:index, :new, :create, :home, :register_for_videochat, :find_remote_user_for_videochat]
  before_filter :ensure_self_account, :only =>[:edit, :update]
  before_filter :ensure_admin_login, :only =>[:update_parameter]

  #REMINDER: uncomment only in production
  #before_filter :force_ssl, :only => ['payment_info']
  #before_filter :remove_ssl, :only => ['home']

  def index
    @tab  = params[:t] ? params[:t] : User::SESSION_TAB
    if User::PAYMENT_TAB == @tab
      @card_detail = current_user.card_detail || CardDetail.new
    elsif User::SESSION_TAB == @tab
      @conversations = current_user.corresponding_user.conversations
    end
  end

  def home
    if current_user and current_user.is_lawyer?
      redirect_to users_path(:t=>'l')
    end
    @lawyers = Lawyer.home_page_lawyers
  end

  def show
    begin
      @user = User.find params[:id]
      @user = Lawyer.find(@user.id) if @user.is_lawyer?
#      @tab  = params[:t] ? params[:t] : User::ACCOUNT_TAB
      @tab  = params[:t] ? params[:t] : User::SESSION_TAB
      if User::PAYMENT_TAB == @tab
        @card_detail = current_user.card_detail || CardDetail.new
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
    redirect_to root_path and return if current_user
    user_type   = params[:ut] || '0'
    if user_type == '0'
      @user       = User.new(:user_type => User::CLIENT_TYPE  )
    else
      @user       = Lawyer.new(:user_type => User::LAWYER_TYPE )
    end
  end

  def create
    redirect_to root_path and return if current_user
    user_type = params[:user_type]
    @user     = user_type == User::LAWYER_TYPE ? Lawyer.new(params[:lawyer]) : User.new(params[:user])
    @user.user_type = user_type

    if @user.save
      session[:user_id] = @user.id
      if @user.is_client?
        redirect_to :action => :payment_info
        # @card_detail = CardDetail.new
        # render :action => 'payment_info' and return
      else
        redirect_to root_path, :notice =>'Account successfully created!'
      end
    else
      render :action =>:new, :ut =>user_type == User::LAWYER_TYPE ? '1' : '0'
    end
  end

  def edit
    begin
      @user = User.find(params[:id])
      @user = Lawyer.find(@user.id) if @user.is_lawyer?
    rescue
      redirect_to root_path, :notice =>"Couldn't find any record"
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.is_lawyer?
      @user  = Lawyer.find(@user.id)
      status = @user.update_attributes(params[:lawyer])
    else
      status = @user.update_attributes(params[:user])
    end
    unless params[:return_url].blank?
      @msg = status ? 'Account Updated Successfully' : nil
      render :action =>:show and return
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
    if request.method == "POST"
#      raise params[:card_detail].inspect
      @card_detail = current_user.card_detail || CardDetail.new(:user_id =>current_user.id)
      if @card_detail.update_attributes(params[:card_detail])
        redirect_to user_path(current_user), :notice => 'Thank you for completing your payment info' and return
      else
        redirect_to root_path and return
      end
    else
      @card_detail = CardDetail.new
    end
  end

  def update_card_detail
    @card_detail = current_user.card_detail || CardDetail.new(:user_id =>current_user.id)
    status       = @card_detail.update_attributes(params[:card_detail])
    unless params[:return_url].blank?
      @msg = status ? 'Account Updated Successfully' : nil
      render :action =>:show and return
    end
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
    redirect_to card_detail_path, :notice =>"You first need to enter your payment info to start chat" and return unless current_user.card_detail
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
    pvalue = params[:value]
    pvalue = pvalue.blank? ? pobj.value : pvalue.strip
    if pobj
      pobj.update_attribute(:value, pvalue)
      render :text =>'Successfully Updated!'
    else
      render :text =>'Update failed!'
    end
  end

  def update_busy_status
    user = User.find(params[:id])
    bool = params[:busy] == 'true' ? true : false
    user.update_attribute(:is_busy, bool)
    render :text => "true", :layout => false
  end

  def register_for_videochat
    u_id = params[:username] if params[:username]
    peer_id = params[:identity] if params[:identity]
    begin
      @user = User.find(u_id)
      @user.peer_id = peer_id
      if @user.save
        render :file=>"users/success.xml", :content_type => 'application/xml', :layout => false
      end
    rescue
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

end

