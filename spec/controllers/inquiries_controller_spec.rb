require 'spec_helper'

describe InquiriesController do
  DatabaseCleaner.clean

  describe "GET show" do
    before :all do
      @inquiry = FactoryGirl.create(:inquiry)
    end

    context "when logged in" do
      before :each do
        @thom = FactoryGirl.create(:lawyer, first_name: "Thom")

        # Sign in as lawyer and go to inquiries#show
        session[:user_id] = @thom.to_param
        get :show, id: @inquiry.to_param
      end

      it "returns http success" do
        response.should be_success
      end

      it "assigns to @bid" do
        assigns(:bid).should be_present
      end
    end

    context "when logged out" do
      before :each do
        session[:user_id] = nil
        get :show, id: @inquiry.to_param
      end

      it "redirects to login page" do
        response.should redirect_to(login_path)
      end

      it "sets a return url" do
        session[:return_to].should eq(inquiry_path(@inquiry.to_param))
      end
    end
  end
end
