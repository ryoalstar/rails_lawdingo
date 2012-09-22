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

  context "#corresponding_user" do

    it "should correspond to a client if user_type is Client" do
      user = User.new(:user_type => User::CLIENT_TYPE)
      user.corresponding_user.should be_a(Client)
    end

    it "should correspond to a lawyer if user_type is Lawyer" do
      user = User.new(:user_type => User::LAWYER_TYPE)
      user.corresponding_user.should be_a(Lawyer)
    end

    it "should correspond to an admin if user_type is Admin" do
      user = User.new(:user_type => User::ADMIN_TYPE)
      user.corresponding_user.should be_a(Admin)
    end

  end

end
