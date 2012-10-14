require "spec_helper"

describe "OfferingsController::Routing" do
  include Rails.application.routes.url_helpers

  context "#edit" do
    it "should route correctly to the offerings/edit" do
      { get: "/offerings/10/edit" }.should route_to(
        controller: "offerings",
        action: "edit",
        id: "10"
      )

      { get: edit_offering_path(10) }.should route_to(
        controller: "offerings",
        action: "edit",
        id: "10"
      )
    end
  end
end
