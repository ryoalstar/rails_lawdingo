module OfferingsHelper
  def form_action_url(user_id, offering_id)
    if params[:action] == "edit"
      offering_path(offering_id)
    else
      user_offerings_path(user_id: user_id, offering_id: offering_id)
    end
  end
end
