require 'spec_helper'

describe UsersController do
  DatabaseCleaner.clean

  include Rails.application.routes.url_helpers

  let(:lawyers) do
    [Lawyer.new]
  end

  it "should build a list of all practice areas for the search" do
    practice_areas = [PracticeArea.new]
    PracticeArea.expects(:parent_practice_areas => practice_areas)
    get(:home)
    assigns["practice_areas"].should eql practice_areas
  end

  context "on sign up" do
    context "when a pending question exists" do
      before :each do
        @question = FactoryGirl.create(:question, user_id: nil)
        @stefan = FactoryGirl.build(:user, email: "stefan@lawdingo.com")
        session[:question_id] = @question.id
      end

      it "should update question user data" do
        post :create, user: @stefan.attributes
        @question.user_id.should == @stefan.id
      end

      # it "should notify admin by email" do
      #   expect {
      #     post :create, user: @stefan.attributes
      #   }.to change(ActionMailer::Base.deliveries, :size).by(1)

      #   question_email = ActionMailer::Base.deliveries.last
      #   question_email.subject.should match /Question ##{@question.id}/
      # end
    end
  end

  context "on starting a phone call" do
    before :each do
      @james = FactoryGirl.create(:client, first_name: "James", phone: "")
      @morgan = FactoryGirl.create(:lawyer, first_name: "Morgan")

      # sign in as James (client)
      session[:user_id] = @james.to_param
    end

    it "should remember client's phone number" do
      number = "1234567890"
      post :create_phone_call, { lawyer_id: @morgan.to_param, client_number: number }
      response.should redirect_to controller: "users", action: "start_phone_call", id: @morgan.to_param, notice: "Error: making a call"
      User.find(session[:user_id]).phone.should eq(number)
    end
  end

  context "came to sign up page from root" do
    before :each do
      @request.stubs(:referer).returns(root_url(host: "localhost"))
    end

    it "set session[:return_to] to nil" do
      get :new
      session[:return_to].should eq(nil)
    end
  end

  context "#create_lawyer_request" do
    it "should send an email with lawyer request" do
      expect {
        post :create_lawyer_request, request_body: "Something new."
      }.to change(ActionMailer::Base.deliveries, :size).by(1)

      email = ActionMailer::Base.deliveries.last
      email.to.should include "info@lawdingo.com"
      email.subject.should match /New lawyer request/
      email.body.should match /Something new/
    end
  end

  context "#admin_is_editing_layer" do
    before :each do
      @admin = FactoryGirl.create(:admin)
      session[:user_id] = @admin.id
      @schoolA = FactoryGirl.create(:school, :name=>'A-School')
      @schoolC = FactoryGirl.create(:school, :name=>'C-School')
      @schoolB = FactoryGirl.create(:school, :name=>'B-School')
      
    end
    
    it "should show the schools in alphabetical order" do
      lawyer = FactoryGirl.create(:lawyer)
      get :edit, :id=>lawyer.id
      school_list = assigns(:schools)
      school_list.should_not be_nil
      
      school_list.at(0).should eq(@schoolA)
      school_list.at(1).should eq(@schoolB)
      school_list.at(2).should eq(@schoolC)
      
      
    end
    
  end

end
