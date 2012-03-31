require 'spec_helper'

describe "UsersController::Routing" do
  it "should provide routes for the main search page with
    state, service_type, and practice_area" do

    url = "/lawyers/Legal-Services/New-York-lawyers/Blah"

    {:get => url}.should route_to({
      :controller => "users",
      :action => "home",
      :state => "New-York-lawyers",
      :service_type => "Legal-Services",
      :practice_area => "Blah"
    })

  end

  it "should provide routes for the main search page with
    state, service_type, and practice_area" do

    url = "/lawyers/Legal-Services/New-York-lawyers/Blah/Baz"

    {:get => url}.should route_to({
      :controller => "users",
      :action => "home",
      :state => "New-York-lawyers",
      :service_type => "Legal-Services",
      :practice_area => "Blah",
      :practice_subarea => "Baz"
    })

  end

end