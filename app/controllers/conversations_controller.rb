class ConversationsController < ApplicationController
  before_filter :authenticate
  
  def index
    @conversations = current_user.corresponding_user.conversations
  end

  def new
    conversation = Conversation.create_conversation(params[:conversation])
    redirect_to conversation_summary_path(conversation)
  end

  # flash application calls this action
  # after completion it returns 0(in case of failure)
  # or
  # the id of the newly created conversation
  # then the flash redirects to the review page for this conversation
  def create
    conversation = Conversation.create_conversation(params[:conversation])
    render :text => conversation ? conversation.id.to_s : "0"
  end

  def review
    begin
      @conversation = Conversation.find params[:conversation_id]
    rescue
      @conversation = nil
    end
  end

  def summary
    begin
      @conversation = Conversation.find params[:conversation_id]
    rescue
      @conversation = nil
    end
  end

end
