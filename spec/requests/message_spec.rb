require 'spec_helper'

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
      client = FactoryGirl.create(:client)
      lawyer = FactoryGirl.build(:lawyer)
      visit lawyers_path
      click_link(lawyer.full_name)
      sleep SLEEP
      click_link('schedule_session_button')
      sleep SLEEP
      page.has_css?("div#schedule_session").should be_true
      fill_in("message", :with => 'Yahoo')
      click_link('send_message_button')
      sleep SLEEP
      page.current_path.should eql(new_client_path)
    end
  end  

end
