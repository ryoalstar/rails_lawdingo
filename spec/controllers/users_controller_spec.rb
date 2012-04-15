require 'spec_helper'

describe UsersController do

  include Rails.application.routes.url_helpers

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

      cali = State.new(:name => "California")
      State.stubs(:name_like).returns([cali])


      Lawyer.expects(:approved_lawyers => Lawyer)
      Lawyer.expects(:practices_in_state).with(cali).returns(lawyers)

      get(:home, :state => "California-lawyers")
      assigns["lawyers"].should eql lawyers

    end

    it "replaces - with ' ' when provided with states" do
      new_york = State.new(:name => "New York")
      State.stubs(:name_like).returns([new_york])

      Lawyer.expects(:approved_lawyers => Lawyer)
      Lawyer.expects(:practices_in_state).with(new_york).returns(lawyers)

      get(:home, :state => "New-York-lawyers")
      assigns["lawyers"].should eql lawyers
    end

    it "allows for ' ' when provided with states" do

      new_york = State.new(:name => "New York")
      State.stubs(:name_like).returns([new_york])

      Lawyer.expects(:approved_lawyers => Lawyer)
      Lawyer.expects(:practices_in_state).with(new_york).returns(lawyers)

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

    it "assigns selected_state when a state is provided" do

      s = State.new(:name => "New York")
      State.expects(:name_like).with("New York").returns([s])

      Lawyer.expects(:approved_lawyers => Lawyer)
      Lawyer.expects(:practices_in_state).with(s).returns(lawyers)

      get(:home, :state => "New York-lawyers")
      assigns["lawyers"].should eql lawyers
      assigns["selected_state"].should be s

    end

    context "auto-selected state names" do
      
      it "should redirect to the correct state if we can find one" do

        state = State.new
        state.stubs(:name => "California")

        State.expects(:find_by_abbreviation).with("CA").returns(state)
        request.location.stubs(:state_code => "CA")

        get(:home)

        response.should redirect_to(url_for({
          :host => "test.host",
          :controller => :users, 
          :action => :home,
          :service_type => "Legal-Advice",
          :state => "California-lawyers"
        }))

      end

      it "should not override the state provided by the request" do

        cali = State.new(:name => "California")
        new_york = State.new(:name => "New York")
        State.stubs(:name_like).returns([new_york])

        State.stubs(:find_by_abbreviation).with("CA").returns(cali)
        request.location.stubs(:state_code => "CA")

        Lawyer.expects(:approved_lawyers => Lawyer)
        Lawyer.expects(:practices_in_state).with(new_york).returns(lawyers)

        get(:home, :state => "New-York")

      end
    end

  end

  it "should use the offers_practice_area scope when provided with 
    a practice area in the search" do

    pa = PracticeArea.new(:name => "Blah Blah")
    PracticeArea.expects(:name_like).with("Blah-Blah").returns([pa])

    Lawyer.expects(:approved_lawyers => Lawyer)
    Lawyer.expects(:offers_practice_area).with(pa)
      .returns(lawyers)

    get(:home, :practice_area => "Blah-Blah")

    assigns["selected_practice_area"].should be pa

  end

  it "should build a list of all practice areas for the search" do
    practice_areas = [PracticeArea.new]
    PracticeArea.expects(:parent_practice_areas => practice_areas)
    get(:home)
    assigns["practice_areas"].should eql practice_areas
  end

  context "on sign up" do
    context "when a pending question exists" do
      before :each do
        @question = FactoryGirl.create(:question, user_id: nil)
        @stefan = FactoryGirl.build(:user, email: "stefan@lawdingo.com")
        session[:question_id] = @question.id
      end

      it "should update question user data" do
        post :create, user: @stefan.attributes
        @question.user_id.should == @stefan.id
      end

      # it "should notify admin by email" do
      #   expect {
      #     post :create, user: @stefan.attributes
      #   }.to change(ActionMailer::Base.deliveries, :size).by(1)

      #   question_email = ActionMailer::Base.deliveries.last
      #   question_email.subject.should match /Question ##{@question.id}/
      # end
    end
  end
end
