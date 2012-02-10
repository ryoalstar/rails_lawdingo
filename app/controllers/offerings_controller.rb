class OfferingsController < ApplicationController
  before_filter :authenticate, :ensure_self_account

  def index
    @lawyer = User.find(params[:user_id])
    @offering = @lawyer.offerings.new
  end

  def create
    @lawyer = User.find(params[:user_id])
    @offering = @lawyer.offerings.new(params[:offering])

    if @offering.save
      redirect_to user_offerings_path(@lawyer)
    else
      redirect_to user_offerings_path, notice: "Error saving an offering."
    end
  end

  private

    def ensure_self_account
      @user = User.find(params[:user_id])
      
      unless logged_in? and ((@user.id == current_user.id) or logged_in_admin?)
        redirect_to root_path, notice: "Access denied."
      end
    end
end

