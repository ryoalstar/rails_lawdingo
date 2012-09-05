require 'spec_helper'

# Require Twilio constants, because otherwise they don't get loaded here
require "#{Rails.root}/config/initializers/twilio_constants.rb"

describe TwilioController do
  before :each do
    @call = FactoryGirl.create(:call)
  end

  it "should render TwiML response text" do
    get :welcome, lawyer_number: "7743362718", CallSid: @call.sid

    response.body.should =~ /<Response>/
  end
end
