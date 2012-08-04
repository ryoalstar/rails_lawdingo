require 'spec_helper'

describe Bid do
  DatabaseCleaner.clean

  context "on charging a bid" do
    it "returns Stripe::Charge object with paid: true: if payment was successful" do
      @inquiry = FactoryGirl.create(:inquiry)
      @brian = FactoryGirl.create(:lawyer, stripe_customer_token: "cus_PqhSJctocrjC3B")
      @bid = @inquiry.bids.create(lawyer_id: @brian.to_param, amount: 13)

      @bid.charge.should be_kind_of Stripe::Charge
      @bid.charge.paid.should be_true
    end
  end
end
