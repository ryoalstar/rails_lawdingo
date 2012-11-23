class PasswordResetsController < ApplicationController
  
  before_filter :logout_user, :only => :new

  def create
    begin
      user = User.find_by_email(params[:email])
    rescue
      user = nil
    end
    if user
      user.send_password_reset
      redirect_to login_path, :notice => "Thanks - please check your email for instructions on resetting your password."
    else
      redirect_to new_password_reset_path, :notice => "Hmm.. it doesn't look like there's an account with that email."
    end
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 30.minutes.ago
      redirect_to new_password_reset_path, :alert => "Password reset has expired."
    elsif @user.update_attributes(params[:user])
      redirect_to login_path, :notice => "Password has been reset."
    else
      render :edit
    end
  end

end

