require 'spec_helper' 

describe LawyersController do
  
  include Rails.application.routes.url_helpers
  
  DatabaseCleaner.clean
  
  context "POST #create" do

    it "should send a signup notification" do
      Lawyer.any_instance.stubs(:save => true)
      UserMailer.expects(:notify_lawyer_application)
        .with(instance_of(Lawyer))
        .returns(stub(:deliver => true))
      post(:create)
    end

    it "should log in the user by setting the session[:user_id]
      and @current_user" do
      Lawyer.any_instance.stubs(:save => true, :id => 132)
      post(:create)

      session[:user_id].should eql(132)
      assigns[:current_user].should be_instance_of(Lawyer)
    end

    it "should redirect to the pricing page by default" do
      Lawyer.any_instance.stubs(:save => true)
      post :create
      response.should render_template(:pricing)
    end

  end
  
  context "#call_payment" do
    before :each do
      controller.stubs(:current_user).returns(harry)
      controller.stubs(:authenticate).returns(harry)
      Lawyer.expects(:find).with(arnold.id.to_s).returns(arnold)

      request.host = "localhost:3000"
    end

    let :harry do
      FactoryGirl.build_stubbed(:client, first_name: "Harry", stripe_customer_token: nil)
    end

    let :arnold do
      FactoryGirl.build_stubbed(:lawyer, first_name: "Arnold")
    end

    it "should assign to @lawyer" do
      get :call_payment, id: arnold.id
      assigns(:lawyer).should eq arnold
    end

    context "should set the return_path in session array" do
      it "to the phonecall_url if params[:type] is nil" do
        get :call_payment, id: arnold.id
        session[:return_path].should eq phonecall_url(id: arnold.id, host: "localhost:3000")
      end

      it "to the user_chat_session_url if params[:type] is \"video-chat\"" do
        get :call_payment, id: arnold.id, type: "video-chat"
        session[:return_path].should eq user_chat_session_url(user_id: arnold.id, host: "localhost:3000")
      end
    end
  end

end

