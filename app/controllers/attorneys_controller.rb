class AttorneysController < ApplicationController
  before_filter :authenticate, only: :call_payment

  def show
    @attorney = Lawyer.find(params[:id])
    check_approval
    @video = Framey::Video.find_by_creator_id(@attorney.id) if @attorney.has_video?
    @areas = @attorney.areas_human_list 
    @practice_areas = PracticeArea.parent_practice_areas
    @states = State.with_approved_lawyers
  end

  def call_payment
    @lawyer = Lawyer.find(params[:id])

    if params[:type] == "video-chat"
      session[:return_path] = user_chat_session_url(user_id: @lawyer.id)
    elsif params[:type] == "appointment"
      session[:return_path] = lawyers_path
    else
      session[:return_path] = phonecall_url(id: @lawyer.id)
    end
  end

  private

  def check_approval
    redirect_to lawyers_path, notice: "Sorry, this lawyer's bar membership hasn't been verified just yet." unless @attorney.is_approved || @attorney.directory_only?
  end
end
