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
      return_path = ""
      if user.is_client?
       if session[:return_to]
        return_path = session[:return_to]
        session[:return_to] = nil
       else
        return_path = lawyers_path
       end
      elsif user.is_lawyer?
        # redirect the lawyer to the session summary page
        return_path = user_path(current_user, :t=>'l')
      elsif user.is_admin?
        return_path = user_path(user.id)
      end
      if session[:referred_url]
       return_path = session[:referred_url]
       session[:referred_url] = nil
      end
      redirect_to return_path, :notice => "Welcome <b> #{user.full_name} !</b> You have logged in successfully."
    else
      @msg = "You have entered incorrect login credintial."
      render :action => 'new'
    end
  end

  def destroy
    begin
      logout_user
      redirect_to lawyers_path, :notice => "You successfully logged out"
    rescue
      redirect_to lawyers_path
    end
  end

  private

end

