class LawyersController < ApplicationController
  
  before_filter :logout_user, :only => [:new, :create], :if => :logged_in?

  def index
    @users  = Lawyer.non_directory.reverse_order
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
      # redirect to the subscription
      return redirect_to(new_stripe_path)
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
  
  def states
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

  
end

