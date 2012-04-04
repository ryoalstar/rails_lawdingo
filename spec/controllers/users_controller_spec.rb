require 'spec_helper'

describe UsersController do

  let(:lawyers) do
    [Lawyer.new]
  end

  it "should assign all approved lawyers who provide legal advice to the 
    to the default search action" do

    Lawyer.expects(
      :approved_lawyers => Lawyer,
      :offers_legal_advice => lawyers
    )
    get(:home)
    assigns["lawyers"].should eql lawyers

  end

  it "should use the offers_legal_services scope when 
    the service_type param is Legal-Services" do

    Lawyer.expects(
      :approved_lawyers => Lawyer,
      :offers_legal_services => lawyers
    )
    get(:home, :service_type => "Legal-Services")
    assigns["lawyers"].should eql lawyers

  end

  it "should use the offers_legal_advice scope when 
    the service_type param is Legal-Advice" do

    Lawyer.expects(
      :approved_lawyers => Lawyer,
      :offers_legal_advice => lawyers
    )
    get(:home, :service_type => "Legal-Advice")
    assigns["lawyers"].should eql lawyers

  end

  context "State names" do

    it "should assign an array of states for the select box 
      all of which have lawyers in them" do

      states = [State.new]
      State.expects(:with_approved_lawyers => states)

      get(:home)
      assigns["states"].should eql states

    end

    it "should use the practices_in_state scope when the state param
      is a valid state" do

      Lawyer.expects(:approved_lawyers => Lawyer)
      Lawyer.expects(:practices_in_state).with("California").returns(lawyers)

      get(:home, :state => "California-lawyers")
      assigns["lawyers"].should eql lawyers

    end

    it "replaces - with ' ' when provided with states" do
      Lawyer.expects(:approved_lawyers => Lawyer)
      Lawyer.expects(:practices_in_state).with("New York").returns(lawyers)

      get(:home, :state => "New-York-lawyers")
      assigns["lawyers"].should eql lawyers
    end

    it "allows for ' ' when provided with states" do
      Lawyer.expects(:approved_lawyers => Lawyer)
      Lawyer.expects(:practices_in_state).with("New York").returns(lawyers)

      get(:home, :state => "New York-lawyers")
      assigns["lawyers"].should eql lawyers
    end

    it "uses All-States as the URL placeholder to find lawyers in every
      state" do

      Lawyer.expects(
        :approved_lawyers => Lawyer,
        :offers_legal_advice => lawyers
      )
      Lawyer.expects(:practices_in_state).never

      get(:home, :state => "All-States")
      assigns["lawyers"].should eql lawyers

    end

    context "auto-selected state names" do
      
      it "should redirect to the correct state if we can find one" do

        state = State.new
        state.stubs(:name => "California")

        State.expects(:find_by_abbreviation).with("CA").returns(state)
        request.location.stubs(:state_code => "CA")

        get(:home)

        response.should redirect_to({
          :controller => :users, 
          :action => :home,
          :service_type => "Legal-Advice",
          :practice_area => "All",
          :state => "California-lawyers"
        })

      end

      it "should not override the state provided by the request" do

        state = State.new
        state.stubs(:name => "California")

        State.stubs(:find_by_abbreviation).with("CA").returns(state)
        request.location.stubs(:state_code => "CA")

        Lawyer.expects(:approved_lawyers => Lawyer)
        Lawyer.expects(:practices_in_state).with("New York").returns(lawyers)

        get(:home, :state => "New-York")

      end


    end


  end

  it "should use the offers_practice_area scope when provided with 
    a practice area in the search" do

      Lawyer.expects(:approved_lawyers => Lawyer)
      Lawyer.expects(:offers_practice_area).with("Blah-Blah")
        .returns(lawyers)

      get(:home, :practice_area => "Blah-Blah")
      assigns["lawyers"].should eql lawyers
  end


  it "should build a list of all practice areas for the search" do
    practice_areas = [PracticeArea.new]
    PracticeArea.expects(:parent_practice_areas => practice_areas)
    get(:home)
    assigns["practice_areas"].should eql practice_areas
  end
end
