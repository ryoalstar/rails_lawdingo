require 'spec_helper'

describe DailyHoursController do

  let(:lawyer) do
    lawyer = Lawyer.new
    lawyer.stubs(:id => 4)
    lawyer
  end

  before(:each) do
    Lawyer.expects(:find).with("4").returns(lawyer)
  end

  context "GET /users/:id/daily_hours" do

    it "should show all lawyer_daily_hours for a lawyer" do

      daily_hours = [DailyHour.new]
      
      lawyer.expects(:daily_hours).returns(daily_hours)

      get(:index, :user_id => "4")

      assigns["lawyer"].should eql(lawyer)
      assigns["daily_hours"].should eql(daily_hours)

    end

  end

  context "PUT /users/:id/daily_hours" do

    it "should create a new set of daily_hours for the lawyer" do

      dh = {
        "1" => {:start_time => 800, :end_time => 1200}
      }
      # 
      lawyer.stubs(:save => true)

      put(:update, :user_id => "4", :daily_hours => dh)

      assigns["lawyer"].should eql(lawyer)
      # should have 7 daily_hours

      lawyer.daily_hours.length.should eql(7)
      # default to -1
      lawyer.daily_hours.on_wday(2).start_time.should eql(-1)
      # except for the one we posted
      lawyer.daily_hours.on_wday(1).start_time.should eql(800)

    end

  end


end
