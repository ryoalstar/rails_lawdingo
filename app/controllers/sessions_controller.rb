class SessionsController < ApplicationController

  def new
    if logged_in?
    	redirect_to root_path and return
    end
	end

  def create
    if user = User.authenticate(params[:email], params[:password])
      reset_user_session(user)
      login_in_user(user)
      if user.is_client?
        home_path = lawyers_path
      elsif user.is_lawyer?
        # redirect the lawyer to the session summary page
        home_path = user_path(current_user, :t=>'l')
      elsif user.is_admin?
        home_path = user_path(user.id)
      end
      redirect_to home_path, :notice => "Welcome <b> #{user.full_name} !</b> You have logged in successfully."
    else
      @msg = "You have entered incorrect login credintial."
      render :action => 'new'
    end
  end

  def destroy
    begin
      logout_user
      redirect_to root_path, :notice => "You successfully logged out"
    rescue
      redirect_to root_path
    end
  end

  private

  def login_in_user user
    user.update_attributes(:is_online => true, :last_login => Time.now, :last_online => Time.now)
    session[:user_id] = user.id
  end

  def logout_user
    current_user.update_attributes(:is_online =>false, :is_busy =>false, :peer_id =>'0', :last_online => Time.now)
    session[:user_id] = nil
  end

  def reset_user_session user
    user.update_attributes(:is_online =>false, :is_busy =>false, :peer_id =>'0')
  end

end

