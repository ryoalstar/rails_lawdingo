class ContactController < ApplicationController
  def index
    
  end
  
  def send_email
    @error = false
    
    if params[:name].blank? || params[:email].blank? || params[:message].blank?
      @error = true
    else
      ContactMailer.contact_email(params[:name], params[:email], params[:message]).deliver
    end
    
  end
  
  def new_subscriber
    @error = false
    
    if params[:email].blank?
      @error = true
    else
      ContactMailer.new_subscriber(params[:email]).deliver
    end
  end
end
