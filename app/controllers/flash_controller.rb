class FlashController < ApplicationController
  layout false
  def notice
    flash[:notice] = params[:message] if params[:message]
    render :nothing => true
  end
  def alert
    flash[:alert] = params[:message] if params[:message]
    render :nothing => true
  end
end
