class StripesController < ApplicationController

	before_filter :authenticate
	before_filter :check_access, :only => [:new, :create, :coupon_validate]

	def new
		@lawyer.create_stripe_customer! unless @lawyer.stripe_customer_token
	end

	def create
		respond_to do |format|
			if @lawyer.subscribed? # && params[:coupon].empty?
				format.html { redirect_to user_offerings_path(@lawyer, :ft => true), :error => "You are subscribed already!" }
        format.json { render json: @lawyer, status: :ok }
      elsif params[:card] && @lawyer.create_stripe_card(params[:card]) # && @lawyer.apply_coupon(params[:coupon]) # && @lawyer.subscribe! l
        format.html { redirect_to user_offerings_path(@lawyer, :ft => true), :notice => "Thank you for subscribing!" }
        format.json { render json: @lawyer, status: :created, location: @lawyer } 
      elsif params[:coupon].present? && @lawyer.apply_coupon(params[:coupon])
        format.html { redirect_to user_offerings_path(@lawyer, :ft => true), :notice => "Thank you for subscribing! Your coupon applied!" }
        format.json { render json: @lawyer, status: :ok, location: @lawyer } 
      else
        format.html { render action: "new", :error => "Error. Something wrong." }
        format.json { render json: @lawyer.errors, status: :unprocessable_entity }
      end
    end
	end

	def coupon_validate
		respond_to do |format|
			if @lawyer.coupon_valid?(params[:coupon], false)
				format.html { render :nothing => true }
        format.json { render json: {:result => true, :coupon => @lawyer.stripe_get_coupon(params[:coupon])}, status: :ok }
      else
				format.html { render :nothing => true }
        format.json { render json: {:result => false, :errors => @lawyer.errors}, status: :ok }
      end
    end
	end	

	private

	def check_access
		redirect_to root_path, :status => :unauthorized unless current_user.is_lawyer?
		@lawyer = current_user
		@stripe_plan = Lawyer::get_stripe_plan
	end

end
