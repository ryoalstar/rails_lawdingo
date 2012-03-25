require 'spec_helper'

describe "users/home" do

  let(:lawyer) do
    l = Lawyer.new
    l.stubs(:last_name => "Blah", :id => 1)
    l
  end

  shared_examples_for "rendering" do
    before(:each) do
      
      pa = PracticeArea.new(:name => "My Practice Area")
      pxy = stub(
        :with_approved_lawyers => [
          PracticeArea.new(:name => "Another Practice Area")
        ]
      )
      pa.stubs(:children => pxy)

      assign(:lawyers, [lawyer])
      assign(:states, [State.new(:name => "New York")])
      assign(:practice_areas, [pa])
    end
    # we should display lawyer data
    it "should display the lawyer's last name" do
      render
      rendered.should =~ /#{lawyer.last_name}/
    end

    it "should have a form tag and elements" do
      render 
      rendered.should have_selector("form.filters")
    end

    it "should display the filters for service_type" do
      render
      rendered.should have_selector("div#service_type")
      rendered.should have_selector(
        "div#service_type input[value='Legal-Services']"
      )
      rendered.should have_selector(
        "div#service_type input[value='Legal-Advice']"
      )
    end

    it "should display the filters for state" do
      render
      rendered.should have_selector("div#state")
      rendered.should have_selector(
        "div#state select[name='state']"
      )
      rendered.should have_selector(
        "div#state select option[value='All-States']"
      )
      rendered.should have_selector(
        "div#state select option[value='New-York-lawyers']"
      )
    end

    it "should display the practice areas" do
      render
      rendered.should have_selector("div#practice_areas")
      rendered.should have_selector(
        "div#practice_areas input[value=All]"
      )
      rendered.should have_selector(
        "div#practice_areas input[value=My-Practice-Area]"
      )
      rendered.should have_selector(
        "div#practice_areas input[value=Another-Practice-Area]"
      )
    end

  end

  context "not logged in" do
    before(:each) do
      view.stubs(
        :logged_in? => false
      )
    end
    it_should_behave_like "rendering"
  end

  context "logged in" do
    before(:each) do
      view.stubs(
        :logged_in? => true,
        :current_user => User.new
      )
    end
    it_should_behave_like "rendering"
  end

end
