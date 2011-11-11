class SessionsController < ApplicationController

  def new
    if logged_in?
    	redirect_to root_path and return
    end
	end

  def create
    if user = User.authenticate(params[:email], params[:password])
      login_in_user(user.id)
      if user.is_client?
        home_path = root_path
      elsif user.is_lawyer?
        # redirect the lawyer to the session summary page
        home_path = user_path(current_user, :t=>'l')
      elsif user.is_admin?
        home_path = user_path(user.id)
      end
      user.is_online = true
      user.save
      redirect_to home_path, :notice => "Welcome <b> #{user.full_name} !</b> You have logged in successfully."
    else
      flash.now[:notice] = "You have entered incorrect login credintial."
      render :action => 'new'
    end
  end

  def destroy
    current_user.is_online = false
    current_user.save
    logout_user
    redirect_to login_path, :notice => "You successfully logged out"
  end

  private

  def login_in_user user_id
    session[:user_id] = user_id
  end

  def logout_user
    session[:user_id] = nil
  end

end

