require 'spec_helper'

describe Lawyer do
  
  it "should provide an offers_legal_services scope" do
    scope = Lawyer.offers_legal_services
    
    scope.includes_values.should eql([:offerings])
    scope.where_values.should eql(["offerings.id IS NOT NULL"])
  end
  
  it "should provide an offers_legal_advice scope" do
    scope = Lawyer.offers_legal_advice
    scope.includes_values.should eql([:practice_areas])
    scope.where_values.should eql(["practice_areas.id IS NOT NULL"])
  end
  
  it "should provide a practices_in_state scope" do
    scope = Lawyer.practices_in_state("New York")
    scope.includes_values.should eql([:states])
    scope.where_values.should eql(["states.name = 'New York'"])
  end

  context "offers_practice_area scope" do
    it "should provide an offers_practice_area scope" do
      pa = PracticeArea.new
      pa.stubs(:id => 9489)

      PracticeArea.expects(:name_like).with("Blah").returns([pa])

      scope = Lawyer.offers_practice_area("Blah")
      scope.includes_values.should eql([:offerings, :practice_areas])

      where_values = [
        "practice_areas.id = #{pa.id} OR offerings.practice_area_id = #{pa.id}"
      ]

      scope.where_values.should eql(where_values)
    end

    it "should handle when an invalid practice area name is passed" do
      PracticeArea.expects(:name_like).with("Blah-Blah").returns([])

      scope = Lawyer.offers_practice_area("Blah-Blah")
      scope.includes_values.should eql([:offerings, :practice_areas])

      where_values = [
        "practice_areas.id = 0 OR offerings.practice_area_id = 0"
      ]

      scope.where_values.should eql(where_values)
    end
  end

  

end
