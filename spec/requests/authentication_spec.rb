require 'spec_helper'

describe "Authentication" do

  include Rails.application.routes.url_helpers
  
  before(:all) do
    DatabaseCleaner.clean
    AppParameter.set_defaults
    FactoryGirl.create(:homepage_image)
  end

  context "registered as client" do
    it "redirects to lawyers page if user came from home page" do
      sign_up_from_root
      current_url.should eq(lawyers_url)
    end
  end
 
  def sign_up_from_root
    @roland = FactoryGirl.build(:client, first_name: "Roland")
    visit root_path
    click_link "Client Signup"
    page.fill_in "user_first_name", with: @roland.first_name
    page.fill_in "user_last_name", with: @roland.last_name
    page.fill_in "user_email", with: @roland.email
    page.fill_in "user_password", with: @roland.password
    click_button "submit_signup"
  end
end
