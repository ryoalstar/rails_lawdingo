require 'spec_helper'

describe Message do
  DatabaseCleaner.clean
  subject { FactoryGirl.create(:message) }
  specify { should belong_to(:client) }
  specify { should belong_to(:lawyer) }
  specify { should validate_presence_of(:client) }
  specify { should validate_presence_of(:lawyer) }
  specify { should validate_presence_of(:body) }
  specify { should be_valid }
end
