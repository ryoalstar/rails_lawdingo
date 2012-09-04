require 'spec_helper'

describe User do
  specify { should belong_to(:school) }
  specify { should have_many(:offerings) }
  specify { should have_many(:questions) }
  specify { should validate_presence_of(:first_name) }
  specify { should validate_presence_of(:last_name) }
  specify { should validate_presence_of(:email) }
  specify { should validate_presence_of(:user_type) }
  specify { should validate_presence_of(:rate) }
  specify { should validate_uniqueness_of(:email) }
  specify { should_not allow_value("asdfghj").for(:phone) }
  specify { should be_valid }
  subject { FactoryGirl.create(:user) }

  describe "timezone" do

    it "timezone_utc_offset" do
      subject.time_zone = 'Lima'
      subject.timezone_utc_offset.should == -5
    end

    it "timezone_abbreviation" do
      subject.time_zone = 'Atlantic Time (Canada)'
      subject.timezone_abbreviation.should == "ADT"
    end

  end

end
