require 'spec_helper'

describe "StripesController::Routing" do
  include Rails.application.routes.url_helpers
  it "should provide route /paid for the new page" do
    {:get => new_stripe_path}.should route_to({
      :controller => "stripes",
      :action => "new"
    })
  end  

  it "should provide route /coupon_validate for the coupon_validate page" do
    {:post => coupon_validate_stripe_path}.should route_to({
      :controller => "stripes",
      :action => "coupon_validate"
    })
  end
  it "should provide route /stripe for the create page" do
    {:post => stripe_path}.should route_to({
      :controller => "stripes",
      :action => "create"
    })
  end
end
 
