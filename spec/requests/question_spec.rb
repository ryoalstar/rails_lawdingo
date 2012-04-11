require 'spec_helper'

describe "general question for lawyers" do
  it "shows question form only to signed in users" do
    visit lawyers_path
    page.should_not have_selector("div.question-container")

    sign_in
    page.body.should have_selector("div.question-container")
  end

  def sign_in
    user = FactoryGirl.create(:user)
    visit login_path
    page.fill_in "email", with: user.email
    page.fill_in "password", with: "secret"
    click_button "submit_login"
  end
end
