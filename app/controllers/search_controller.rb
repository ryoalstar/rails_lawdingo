class SearchController < ApplicationController
  def populate_specialities
    @practice_area = PracticeArea.find(params[:pid])
    @practice_area_specialities = @practice_area.specialities rescue []
    render :action => 'populate_specialities', :layout => false
  end

  def filter_results
    state_id = params[:state].to_i
    pa_id = params[:pa].to_i
    sp_id = params[:sp].to_i
    @lawyers = []
    @state_lawyers = []
    if state_id == 0
      @state_lawyers = Lawyer.approved_lawyers
    else
      @state_lawyers = State.find(state_id).lawyers.approved_lawyers
    end
    if pa_id == 0
      @lawyers = @state_lawyers
    else
      if sp_id == 0
        @pa_lawyers = PracticeArea.find(pa_id).lawyers.approved_lawyers
      else
        @pa_lawyers = PracticeArea.find(sp_id).lawyers.approved_lawyers
      end
      @lawyers = @state_lawyers & @pa_lawyers
    end
    render :action => "filter_results", :layout =>false
  end
end

