class OfferingsController < ApplicationController
  def index
    @lawyer = User.find(params[:user_id])
    @offering = @lawyer.offerings.new
  end

  def show
    @offering = Offering.find(params[:id])
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
end

