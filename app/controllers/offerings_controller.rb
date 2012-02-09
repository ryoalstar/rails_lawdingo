class OfferingsController < ApplicationController
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
end

