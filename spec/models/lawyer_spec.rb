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
  
  context ".practices_in_state" do

    it "should provide a practices_in_state scope" do
      scope = Lawyer.practices_in_state("New York")
      scope.includes_values.should eql([:states])
      scope.where_values.should eql(["states.name = 'New York'"])
    end

    it "should provide a practices_in_state scope" do
      ny = State.new(:name => "New York")
      scope = Lawyer.practices_in_state(ny)
      scope.includes_values.should eql([:states])
      scope.where_values.should eql(["states.name = 'New York'"])
    end

  end
  

  context ".offers_practice_area" do
    it "should provide an offers_practice_area scope" do
      pa = PracticeArea.new
      pa.stubs(:id => 9489)

      pa2 = PracticeArea.new
      pa2.stubs(:id => 9374)

      pa.stubs(:children => [pa2])

      PracticeArea.expects(:name_like).with("Blah").returns([pa])

      scope = Lawyer.offers_practice_area("Blah")
      scope.includes_values.should eql([:offerings, :practice_areas])

      where_values = [
        "practice_areas.id IN (#{pa.id},#{pa2.id}) " + 
          "OR offerings.practice_area_id IN (#{pa.id},#{pa2.id})"
      ]

      scope.where_values.should eql(where_values)
      
      lambda{scope.count}.should_not raise_error

    end

    it "should handle when an instance of PracticeArea is passed" do
      PracticeArea.expects(:name_like).never
      
      pa = PracticeArea.new(:name => "Blah-Blah")
      pa.stubs(:id => 928)
      
      scope = Lawyer.offers_practice_area(pa)
      scope.includes_values.should eql([:offerings, :practice_areas])

      where_values = [
        "practice_areas.id IN (928) OR offerings.practice_area_id IN (928)"
      ]

      scope.where_values.should eql(where_values)
      lambda{scope.count}.should_not raise_error
    end

    it "should handle when an invalid practice area name is passed" do
      PracticeArea.expects(:name_like).with("Blah-Blah").returns([])

      scope = Lawyer.offers_practice_area("Blah-Blah")
      scope.includes_values.should eql([:offerings, :practice_areas])

      where_values = [
        "practice_areas.id IN (NULL) OR offerings.practice_area_id IN (NULL)"
      ]

      scope.where_values.should eql(where_values)
      lambda{scope.count}.should_not raise_error
    end
  end

  

end
