require 'spec_helper'

describe Admin::QuestionsHelper do
  DatabaseCleaner.clean

  it "searchs matching lawyers and returns their count" do
    
    pending "Assign practice area and a state to lawyers and submit a search"

    FactoryGirl.create :practice_area, name: "Family"
    FactoryGirl.create :state, name: "California"
    %w(Steven Neal Peter).each do |name|
      FactoryGirl.create :lawyer, first_name: name
    end

    
  end

end
