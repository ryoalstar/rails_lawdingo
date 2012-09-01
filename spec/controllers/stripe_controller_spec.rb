require 'spec_helper'

describe StripeController do

  describe "GET 'subscribe_lawyer'" do
    it "returns http success" do
      get 'subscribe_lawyer'
      response.should be_success
    end
  end

end
