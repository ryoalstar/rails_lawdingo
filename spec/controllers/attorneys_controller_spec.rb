require "spec_helper"

describe AttorneysController do
  include Rails.application.routes.url_helpers

  DatabaseCleaner.clean

  context "#call_payment" do
    before :each do
      controller.stubs(:current_user).returns(harry)
      controller.stubs(:authenticate).returns(harry)
      Lawyer.expects(:find).with(arnold.id.to_s).returns(arnold)

      request.host = "localhost:3000"
      get :call_payment, id: arnold.id
    end

    let :harry do
      FactoryGirl.build_stubbed(:client, first_name: "Harry", stripe_customer_token: nil)
    end

    let :arnold do
      FactoryGirl.build_stubbed(:lawyer, first_name: "Arnold")
    end

    it "should assign to @lawyer" do
      assigns(:lawyer).should eq arnold
    end

    it "should set the return_path in session array to the phonecall_url" do
      session[:return_path].should eq phonecall_url(id: arnold.id, host: "localhost:3000")
    end
  end
end
