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
  subject { FactoryGirl.create(:user) }

  describe "validation" do

    it "should be valid" do
      subject.should be_valid
    end

  end

end
