require 'spec_helper'

describe BidsController do
  DatabaseCleaner.clean

  context "#create" do
    before :each do
      @inquiry = FactoryGirl.create(:inquiry)
      @alan = FactoryGirl.create(:lawyer, first_name: "Alan", stripe_customer_token: "cus_PqhSJctocrjC3B")
      @bid = FactoryGirl.build(:bid, amount: 10, lawyer_id: @alan.to_param, inquiry_id: @inquiry.to_param)
    end

    it "send email notification when new bid submitted" do
      expect {
        post :create, bid: @bid.attributes
      }.to change(ActionMailer::Base.deliveries, :size).by(1)

      email = ActionMailer::Base.deliveries.last
      email.to.should include "nikhil.nirmel@gmail.com"
      email.subject.should match /Bid ##{Bid.last.id} submitted/
    end
  end
end
