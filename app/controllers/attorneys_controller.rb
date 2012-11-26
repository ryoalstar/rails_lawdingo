class AttorneysController < ApplicationController
  before_filter :authenticate, only: :call_payment
  before_filter :auto_detect_state, :only => :show
  def show
    @attorney = LawyerDecorator.new(Lawyer.find(params[:id]))

    @areas = @attorney.areas_human_list 
    # set the time zone
    # Time.zone = @attorney.time_zone
    if @attorney.has_video?
      @video = Framey::Video.find_by_creator_id(@attorney.id)
    end

    @practice_areas = PracticeArea.parent_practice_areas
    @states = State.with_approved_lawyers
  end

  def call_payment
    @lawyer = Lawyer.find(params[:id])

    if params[:type] == "video-chat"
      session[:return_path] = user_chat_session_url(user_id: @lawyer.id)
    elsif params[:type] == "appointment"
      @appointment = true
      session[:return_path] = lawyers_path
    else
      session[:return_path] = phonecall_url(id: @lawyer.id)
    end
  end
  
  def directory
    @lawyers = Lawyer.directory.paginate(:page => params[:page], :per_page => 100)

    respond_to do |format|
      format.html # directory.html.haml
      format.json { render json: @lawyers }
    end
  end

  private

  def check_approval
    redirect_to lawyers_path, notice: "Sorry, this lawyer's bar membership hasn't been verified just yet." unless @attorney.is_approved || @attorney.directory_only?
  end
end
