require 'spec_helper'

describe "Restful Lawyers", :integration do
  
  #include Rails.application.routes.url_helpers

  before(:all) do
    DatabaseCleaner.clean
    AppParameter.set_defaults
    FactoryGirl.create(:homepage_image)
  end

  before(:each) do
    Lawyer.delete_all
  end

  let(:practice_area) do
    FactoryGirl.create(:practice_area)
  end

  context "Signing up" do

    it "should create a lawyer" do
      
      lawyer = FactoryGirl.build(:lawyer)

      # create a practice area to select
      practice_area

      lambda{
        visit(new_lawyer_path)
        fill_in("lawyer_first_name", :with => lawyer.first_name)
        fill_in("lawyer_last_name", :with => lawyer.last_name)
        fill_in("lawyer_email", :with => lawyer.email)
        fill_in("lawyer_password", :with => lawyer.password)
        fill_in("lawyer_rate", :with => "200")
        
        check("practice_area_#{practice_area.id}")
        click_button("Apply as a Lawyer")
        
        # base case redirects to lawyers path
        page.current_path.should eql(subscribe_lawyer_path)

        Lawyer.last.practice_areas.should include practice_area

      }.should change{Lawyer.count}.by(1)
    end 

    it "should display error messages when a user fails to be 
      created" do

      lawyer = FactoryGirl.build(:lawyer)

      lambda{
        visit(new_lawyer_path)
        fill_in("lawyer_first_name", :with => lawyer.first_name)
        fill_in("lawyer_last_name", :with => lawyer.last_name)
        fill_in("lawyer_password", :with => lawyer.password)
        click_button("Apply as a Lawyer")
        
        # should render template with error message
        page.should have_selector("div.error_explanation") do
          with_selector("li", :text => "Email is required")
        end

      }.should change{Lawyer.count}.by(0)

    end

  end

  describe "Availability toggles" do

    it "should login/logout right" do
      lawyer = FactoryGirl.create(:lawyer, :is_available_by_phone => false, :password => "secret")
      lawyer.is_online.should be_false
      lawyer.is_available_by_phone.should be_false
      sign_in lawyer
      current_url.should eq(user_daily_hours_url(lawyer.id))
      page.should have_selector('h3.lawyer_notice:contains("You are now shown as available by video chat. Keep this window open to remain available.")')
      lawyer.reload
      lawyer.is_online.should be_true
      lawyer.is_available_by_phone.should be_true
      sign_out
      current_url.should eq(root_url) 
      lawyer.reload
      lawyer.is_online.should be_false
      lawyer.is_available_by_phone.should be_true
    end 

  end 

end
