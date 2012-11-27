require 'spec_helper'

describe MessagesController do

  DatabaseCleaner.clean

  include Rails.application.routes.url_helpers

  let(:lawyers) do
    [Lawyer.new]
  end

  context "#send_email_to_lawyer" do
    render_views

    before :each do
      @amy = FactoryGirl.create(:client, first_name: "Amelia")
      @doctor = FactoryGirl.create(:lawyer, first_name: "The Doctor")
      @message = FactoryGirl.build(:message, :body => "Geronimo!", :lawyer => @doctor, :client => @amy)
      @attributes = { lawyer_id: @doctor.id, email_msg: @message.body, message: @message.attributes }
      session[:user_id] = @amy.to_param
    end

    it "save a message" do
      expect {
        post :send_message_to_lawyer, @attributes
      }.to change(Message, :count).by(1)
      
      message = Message.last
      message.lawyer_id.should eq(@doctor.id)
      message.client_id.should eq(@amy.id)
      message.body.should match /Geronimo!/
      session[:message].should be_nil
      session.delete :user_id
      post :send_message_to_lawyer, @attributes
      response.body.start_with?('{"result":false').should be_true
      session[:message_id].should_not be_nil
    end

    it "send an email to lawyer" do
      expect {
        @message.send!
      }.to change(ActionMailer::Base.deliveries, :size).by(1)

      email = ActionMailer::Base.deliveries.last
      email.to.should include @doctor.email
    end

    it "render result when message is sent" do
      post :send_message_to_lawyer, @attributes
      response.body.start_with?('{"result":true').should be_true
      session.delete :user_id
      post :send_message_to_lawyer, @attributes
      response.body.start_with?('{"result":false').should be_true
    end

    it 'clears session message' do 
      session[:message_id] = @message.id
      get :clear_session_message
      response.should be_true
      session[:message_id].should be_nil
    end
  end

end