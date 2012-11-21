require 'spec_helper'

describe UserMailer do
  DatabaseCleaner.clean
  
  it "should send welcome email to client after create" do
    expect {
      FactoryGirl.create(:client)
    }.to change(ActionMailer::Base.deliveries, :size).by(1)
  end
  
  it "should send welcome email to lawyer after create" do
    pending 'welcome email to lawyer temporarily removed'
    expect {
      FactoryGirl.create(:lawyer)
    }.to change(ActionMailer::Base.deliveries, :size).by(1)
  end

  context "#notify_lawyer_application" do
    before :each do
      @brian = FactoryGirl.create(:lawyer, first_name: "Brian", last_name: "Adams", email: "brian.adams@gmail.com")
      @mailer = UserMailer.notify_lawyer_application(@brian)
    end

    it "should display lawyer email address" do
      @mailer.body.should =~ /#{@brian.email}/
    end

    it "should display lawyer full name" do
      @mailer.body.should =~ /#{@brian.full_name}/
    end
  end

  context "#notify_client_signup" do
    before :each do
      @hanna = FactoryGirl.create(:user, first_name: "Hanna", last_name: "Marciniak", email: "hanka@honestplace.com")
      @mailer = UserMailer.notify_client_signup(@hanna)
    end

    it "should display client email address" do
      @mailer.body.should =~ /#{@hanna.email}/
    end

    it "should display client full name" do
      @mailer.body.should =~ /#{@hanna.full_name}/
    end
  end

  context "#free_inquiry_email" do
    before :all do
      @edward = FactoryGirl.create(:lawyer, first_name: "Edward", email: "edward7@lawdingo.com")
      @question = FactoryGirl.create(:question, body: "Are you my mommy?")
      @mailer = UserMailer.free_inquiry_email(@question, @edward)
    end

    it "should contain inquiries@lawdingo.com in from field" do
      @mailer.from.should include "inquiries@lawdingo.com"
    end
  end

  context "#session_notification" do
    before :each do
      @conversation = FactoryGirl.create(:conversation, start_date: Time.now, end_date: 20.minutes.from_now, billable_time: 5)
      @mailer = UserMailer.session_notification(@conversation)
    end

    it "should display client email address" do
      @mailer.body.should =~ /#{@conversation.client.email}/
    end

    it "should display lawyer email address" do
      @mailer.body.should =~ /#{@conversation.lawyer.email}/
    end

    it "should display session duration" do
      @mailer.body.should =~ /Duration : 20/
    end
  end
end
