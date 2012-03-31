require 'spec_helper'

describe "LawyerSearches" do
  describe "GET /lawyer_searches" do
    before(:each) do
      Lawyer.delete_all
      PracticeArea.delete_all
      State.delete_all

      lawyer = FactoryGirl.create(:lawyer)
      pa1 = FactoryGirl.create(:practice_area)
      pa2 = FactoryGirl.create(
        :practice_area, 
        :main_area => pa1,
        :name => "Another Name"
      )
      lawyer.practice_areas << pa1
      lawyer.practice_areas << pa2
      lawyer.states << FactoryGirl.create(:state)

    end
    
    let(:lawyer) do
      Lawyer.first
    end

    let(:unassigned_state) do
      FactoryGirl.create(:state, :name => "New York")
    end

    it "displays dynamic data on the lawyers page" do
      visit(lawyers_path)

      page.should have_content(lawyer.last_name)
      page.should have_content(PracticeArea.first.name)
      page.should have_content(PracticeArea.last.name)
      page.should have_content(State.first.name)
      
    end

    it "searches for a lawyer by service type" do

      # our lawyer offers legal advice
      visit(lawyers_path(:service_type => "Legal-Advice"))
      page.should have_content(lawyer.last_name)


      # we don't offer any legal services
      visit(lawyers_path(:service_type => "Legal-Services"))
      page.should_not have_content(lawyer.last_name)
    end

    it "searches for a lawyer by state" do
      # we are in CA
      visit(lawyers_path(
        :service_type => "Legal-Advice",
        :state => "#{lawyer.states.first.name}-lawyers"
      ))
      page.should have_content(lawyer.last_name)

      # we are not in NY
      visit(lawyers_path(
        :service_type => "Legal-Advice",
        :state => "#{unassigned_state.name}-lawyers"
      ))
      page.should_not have_content(lawyer.last_name)
    end

    context "Searching by practice area" do

      before(:each) do
        # we want to test practice_areas, which 
        # are different for offerings and legal advice
        lawyer.offerings << FactoryGirl.create(
          :offering, {
            :practice_area => lawyer.practice_areas.first
          }
        )
      end

      it "searches for a lawyer by practice area in Legal-Advice" do

        visit(lawyers_path(
          :service_type => "Legal-Advice",
          :practice_area => lawyer.practice_areas.first.name.gsub(/\s+/,"-")
        ))
        page.should have_content(lawyer.last_name)

        # we are not in NY
        visit(lawyers_path(
          :service_type => "Legal-Advice",
          :practice_area => "gobbldygook"
        ))
        page.should_not have_content(lawyer.last_name)

      end

      it "searches for a lawyer by practice area in Legal-Services" do

        visit(lawyers_path(
          :service_type => "Legal-Services",
          :practice_area => lawyer.practice_areas.first.name.gsub(/\s+/,"-")
        ))
        page.should have_content(lawyer.last_name)

        # no such practice area
        visit(lawyers_path(
          :service_type => "Legal-Services",
          :practice_area => "gobbldygook"
        ))
        page.should_not have_content(lawyer.last_name)

      end

    end

    context "Searching by "

  end
end
