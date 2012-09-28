require 'spec_helper'

describe "MessagesController::Routing" do
  include Rails.application.routes.url_helpers

  it "should provide route '/send_message/:lawyer_id' for the schedule_session action" do
    lawyer = FactoryGirl.create(:lawyer)
    {:post => schedule_session_messages_path(lawyer)}.should route_to({
      :controller => "messages",
      :action => "send_message_to_lawyer",
      :lawyer_id => lawyer.id.to_s
    })
  end

  it "should provide route /messages/clear_session_message for the clear_session_message action" do
    {:get => clear_session_message_messages_path}.should route_to({
      :controller => "messages",
      :action => "clear_session_message"
    })
  end
end
