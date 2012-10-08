require 'spec_helper'

describe "general question for lawyers", :integration do

  context "when is signed in" do
    it "should show question form" do
      sign_in
      page.body.should have_selector("div.question-container")
    end
  end

  def sign_in
    user = FactoryGirl.create(:user)
    visit login_path
    page.fill_in "email", with: user.email
    page.fill_in "password", with: "secret"
    click_button "submit_login"
  end
end

