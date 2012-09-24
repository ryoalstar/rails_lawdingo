require 'spec_helper' 


describe LawyersController do 

  
  context "POST #create" do

    it "should send a signup notification" do
      Lawyer.any_instance.stubs(:save => true, :id => 132)
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

    it "should redirect to the lawyers path by default" do
      Lawyer.any_instance.stubs(:save => true, :id => 132)
      post(:create)
      response.should redirect_to(user_path(132))
    end

  end

end