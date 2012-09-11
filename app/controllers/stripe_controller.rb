class StripeController < ApplicationController

	before_filter :authenticate
    force_ssl

	def subscribe_lawyer
		@lawyer = Lawyer.find(params[:id])
		if request.put? && params[:lawyer][:stripe_card_token].present?
			if @lawyer.save_with_payment params[:lawyer][:stripe_card_token]
			    redirect_to @lawyer, :notice => "Thank you for subscribing!"
			else
				flash[:notice] = "Error. Something wrong."
			end
		end
	end
end
