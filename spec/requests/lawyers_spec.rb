require 'spec_helper'

describe "Restful Lawyers", :integration do
  
  #include Rails.application.routes.url_helpers

  before(:all) do
    DatabaseCleaner.clean
    AppParameter.set_defaults
    @homepage_image = FactoryGirl.create(:homepage_image)
  end

  #before(:each) do
    #Lawyer.delete_all
  #end

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
        fill_in("lawyer_hourly_rate", :with => "200")
        
        check("practice_area_#{practice_area.id}")
        
        click_button("Apply as a Lawyer")
        page.current_path.should eql(lawyers_path)

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

  context "Lawyers list" do
    before(:each) do
      offering = FactoryGirl.create(:offering)
      @offering_link = "a[href='"+ offering_path(offering)  +"']"
      user = FactoryGirl.create(:user)
      sign_in user
      visit(lawyers_path)
    end
    it "should render the offerings links" do
      page.should have_selector("li.offerings_item")
      page.should have_selector("li.offerings_item " + @offering_link) 
    end
    
    #it "the offering links panel should be visible after hover on link" do 
    #  page.find("li.offerings_item " + @offering_link).trigger(:mouseover)
    #  find("li.offerings_item " + @offering_link).should be_visible
    #end
    
  end
  
  context "Lawyers list" do
    before(:each) do
      offering = FactoryGirl.create(:offering)
      @offering_link = "a[href='"+ offering_path(offering)  +"']"
      user = FactoryGirl.create(:user)
      sign_in user
      visit(lawyers_path)
    end
    it "should render the offerings links" do
      page.should have_selector("li.offerings_item")
      page.should have_selector("li.offerings_item " + @offering_link) 
    end
    
  end
  
  
  context "Using practice areas link" do
    before(:each) do
      @lawyer = HomepageImage.all.first.lawyer
      practice_area = FactoryGirl.create(:practice_area)
      @lawyer.practice_areas << practice_area
    end
  end
  
  context "Logged in lawyer" do
    before(:each) do
      @lawyer = FactoryGirl.create(:lawyer, :password => "secret")
      sign_in @lawyer
      visit(user_offerings_path(@lawyer))
    end
    
    
    it "cannot create an flat free offering without fee" do
      lambda{
        fill_in("offering_name", :with => 'Service name')
        click_button("Add flat-fee service")
       }.should change{Offering.count}.by(0)
    end
    
    it "cannot create an flat free offering without name" do
      lambda{
        fill_in("offering_fee", :with => '323')
        click_button("Add flat-fee service")
       }.should change{Offering.count}.by(0)
    end
    
    it "should create a flat free offering with name and fee" do
      lambda{
        fill_in("offering_fee", :with => '323')
        fill_in("offering_name", :with => 'Service name')
        click_button("Add flat-fee service")
        
        page.current_path.should eql(user_offerings_path(@lawyer))

      }.should change{Offering.count}.by(1)
    end
    
  end

end
