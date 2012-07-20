require 'spec_helper'

describe Inquiry do
  DatabaseCleaner.clean

  it "is expired when there's no time left for biding" do
    # Inquiry life time is set to 12 hours (models/inquiry#expired_at)
    @expired_inquiry = FactoryGirl.build(:inquiry, created_at: 2.days.ago)
    @expired_inquiry.expired?.should be_true
  end

  it "returns the third highest bid + 1 as a minimum bid if there are 2 or more bids" do
    @inquiry = FactoryGirl.create(:inquiry)

    [10, 12, 15, 40].each do |amount|
      FactoryGirl.create(:bid, inquiry_id: @inquiry.to_param, amount: amount)
    end

    @inquiry.minimum_bid.should eq(13)
  end
end
