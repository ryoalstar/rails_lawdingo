require 'spec_helper'

describe "general question for lawyers" do

  context "when is signed in" do
    it "should show question form" do
      sign_in
      page.body.should have_selector("div.question-container")
    end
  end

  # context "when user is not signed in" do
  #   context "after sign in" do
  #     it "should show a notice that question is sent" do
  #       visit lawyers_path
  #       page.fill_in "question_body", with: "Are you my mommy?"
  #       click_button "Ask"

  #       page.fill_in "user_first_name", with: "Doctor"
  #       page.fill_in "user_last_name", with: "Who"
  #       page.fill_in "user_email", with: "thedoctor@lawdingo.com"
  #       page.fill_in "user_password", with: "secret"
  #       page.click_button "submit_signup"
  #       # Capybara show an error: undefined method `node_name' for nil:NilClass

  #       page.should have_selector("p.notice")
  #     end
  #   end
  # end

  def sign_in
    user = FactoryGirl.create(:user)
    visit login_path
    page.fill_in "email", with: user.email
    page.fill_in "password", with: "secret"
    click_button "submit_login"
  end
end
