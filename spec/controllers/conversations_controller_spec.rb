require "spec_helper"

describe ConversationsController do
  DatabaseCleaner.clean
  render_views

  context "on conversation summary" do
    before :each do
      # sign in as Brian
      @brian = FactoryGirl.create(:user, email: "brian@lawdingo.com")
      session[:user_id] = @brian.to_param
    end

    context "if conversations duration is 0" do
      before :each do
        @conversation = FactoryGirl.create(:conversation, consultation_type: "video")
        @conversation.stubs(duration: 0)
      end

      it "should not show render new review form" do
        get :summary, conversation_id: @conversation.to_param
        response.should be_success
        response.should_not render_template("reviews/_form")
      end
    end
  end
end
