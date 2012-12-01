class LawyersController < ApplicationController
  
  before_filter :logout_user, :only => [:new, :create], :if => :logged_in?
  before_filter :authenticate, :only => [:pricing, :update, :call_payment]
  before_filter :only_lawyer, :only => [:pricing, :update]
  before_filter :logout_user, :only => :new
  before_filter :auto_detect_state, :only => :show
  
  def show    
    @lawyer = LawyerDecorator.new(Lawyer.find(params[:id]))
    @areas = @lawyer.areas_human_list 
    if @lawyer.has_video?
      @video = Framey::Video.find_by_creator_id(@lawyer.id)
    end

    @practice_areas = PracticeArea.parent_practice_areas
    @states = State.with_approved_lawyers
  end

  def new
    @lawyer = Lawyer.new
    i_want_claim if params[:id]
    fill_states
    @states.count.times do
      @lawyer.bar_memberships.build
    end
  end

  def create    
    @lawyer = Lawyer.new(params[:lawyer])
    @states = State.all
    if @lawyer.save
      self.log_in_user!(@lawyer)
      # deliver our signup notification
      UserMailer.notify_lawyer_application(@lawyer).deliver
      return render(:action => :pricing)
    else
      return render(:action => :new)
    end
  end
  
  # only profile for claim use update action
  # PUT /lawyers/1
  # PUT /lawyers/1.json
  def update    
    @lawyer = Lawyer.find(params[:id])
    fill_states
    @lawyer.bar_memberships.delete_all

    respond_to do |format|
      if @lawyer.update_attributes(params[:lawyer])
        update_lawyers_practice_areas @lawyer
        format.html { redirect_to lawyers_path, notice: 'Your profile was successfully claimed. We need some time to approve it.' }
        format.json { head :no_content }
      else
        format.html { render action: "new" }
        format.json { render json: @lawyer.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def statess    
    @lawyer = Lawyer.find(params[:id]) || not_found
    respond_to do |format|
      format.json { render json: {:states => @lawyer.states.to_a}, status: :ok }
    end
  end
  
  def practice_areas    
    @lawyer = Lawyer.find(params[:id]) || not_found
    respond_to do |format|
      format.json { render json: {:practice_areas => @lawyer.practice_areas.to_a}, status: :ok }
    end
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
  def i_want_claim    
    if params[:id]
      lawyer = Lawyer.find params[:id] || not_found
      if lawyer.directory_only?
        @lawyer = lawyer 
        @filled_states = @lawyer.states
      else
        flash[:notice] = 'You can\'t claim this profile.'
      end
    end
  end
  
  def update_lawyers_practice_areas lawyer    
    lawyer.practice_areas.delete_all
    unless params[:practice_areas].blank?
      practice_areas = params[:practice_areas]
      practice_areas.each{|pid|
        pa = PracticeArea.find(pid)
        if !pa.main_area.nil? && !practice_areas.include?(pa.main_area.id.to_s)
          practice_areas.delete pid
        end
      }
      practice_areas.uniq!
      practice_areas.each{|pid|
        ExpertArea.create(:lawyer_id => lawyer.id, :practice_area_id => pid)
      }
    end
  end
  
  def fill_states    
    @filled_states = @lawyer.states
    unless @filled_states.blank?
      filled_state_ids = []
      @filled_states.each{|state| filled_state_ids << state.id}
      @states = State.where('id not in (?)', filled_state_ids).all
    else
      @states = State.all
    end
  end
  
  def check_approval
    redirect_to lawyers_path, notice: "Sorry, this lawyer's bar membership hasn't been verified just yet." unless @lawyer.is_approved || @lawyer.directory_only?
  end

  
end

