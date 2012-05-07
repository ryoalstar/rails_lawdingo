require 'spec_helper'

describe DailyHour do
  
  context "validation" do

    before(:each) do
      subject.wday = 1
    end

    it "should require that its end_time be greater than its
      start time" do
      subject.start_time = 800
      subject.end_time = 700

      subject.should_not be_valid

      subject.errors.full_messages.should include(
        "Start time must be before end time."
      )
    end

    it "should require that both times be -1 if either is" do
      subject.start_time = -1
      subject.end_time = 700

      subject.should_not be_valid

      subject.errors.full_messages.should include(
        "You must mark both the start time and end time " +
        "as closed for a day."
      )
    end

    it "should allow both start and end time to be -1" do

      subject.start_time = -1
      subject.end_time = -1

      subject.should be_valid

    end

  end

end
