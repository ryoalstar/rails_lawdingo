require 'spec_helper'

# Modified by AF. A logged out user should be redirected to sign up page when pressing the button to send messages.
# This requirement was described by Nikhil. 

describe "Message", :integration do

  SLEEP = 5
  
  include Rails.application.routes.url_helpers
  subject { FactoryGirl.build(:message) }

  describe "sending as guest", :js => true do
    it 'should send message from landing page' do 
      visit root_path
      page.current_path.should eql(root_path)
      click_link('schedule_session_button') 
      page.has_css?("div#schedule_session").should be_true
      fill_in("message", :with => 'Yahoo')
      click_link('send_message_button')
      sleep SLEEP
      page.current_path.should eql(new_client_path)
    end

    it 'should send message from home page' do
      visit lawyers_path
      page.current_path.should eql(lawyers_path)
      click_link('schedule_session_button')
      page.has_css?("div#schedule_session").should be_true
      fill_in("message", :with => 'Yahoo')
      click_link('send_message_button')
      sleep SLEEP
      page.current_path.should eql(new_client_path)
    end

    it 'should send message from lawyers show page' do
      client = FactoryGirl.build(:client)
      lawyer = FactoryGirl.build(:lawyer)
      visit lawyers_path
      click_link(lawyer.full_name)
      sleep SLEEP
      this_lawyer_path = page.current_path
      click_link('schedule_session_button')
      sleep SLEEP
      page.has_css?("div#schedule_session").should be_true
      fill_in("message", :with => 'Yahoo')
      click_link('send_message_button')
      sleep SLEEP
      page.current_path.should eql(new_client_path)
      page.should have_content("To send that message to #{lawyer.first_name} #{lawyer.last_name}, please tell us who you are.")
      expect {
        page.fill_in "client_first_name", with: client.first_name
        page.fill_in "client_last_name", with: client.last_name
        page.fill_in "client_email", with: client.email
        page.fill_in "client_password", with: client.password
        click_button "submit_signup"
        sleep SLEEP
      }.to change(ActionMailer::Base.deliveries, :size).by(2)
      page.current_path.should eql(this_lawyer_path)
      page.should have_content('Your message has been sent.')
    end
  end  

end
