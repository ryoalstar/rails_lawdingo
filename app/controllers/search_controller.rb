class SearchController < ApplicationController
  def populate_specialities
    @practice_area = PracticeArea.find(params[:pid])
    @practice_area_specialities = @practice_area.specialities.order(:name) rescue []
    render :action => 'populate_specialities', :layout => false
  end

  # Temporary method for the next home page
  def populate_specialities_next
    @practice_area = PracticeArea.find(params[:pid])
    @practice_area_specialities = @practice_area.specialities.order(:name) rescue []
    render :action => 'populate_specialities_next', :layout => false
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
        @selected_practice_area = "general #{PracticeArea.find(pa_id).name.downcase}"
        @pa_lawyers = PracticeArea.find(pa_id).lawyers.approved_lawyers
      else
        @selected_practice_area = PracticeArea.find(sp_id).name.downcase
        @pa_lawyers = PracticeArea.find(sp_id).lawyers.approved_lawyers
      end
      @lawyers = @state_lawyers & @pa_lawyers
    end
    render :action => "filter_results", :layout =>false
  end

  def get_homepage_lawyers
     homepage_images = HomepageImage.all
     list = []
     practice_area_text = ""
     homepage_images.each{|image|
     lawyer = image.lawyer
     practice_area_text = "Advising on #{practice_areas_listing(lawyer)}. " unless lawyer.parent_practice_area_string.empty?
     images_hash = Hash.new
     images_hash["url"] = image.photo.url(:large)
     images_hash["title"] = "Attorney #{lawyer.full_name}"
     images_hash["description"] = practice_area_text + "Free consultation, then $#{lawyer.rate}0/minute"
     list<< images_hash
     }
     render :text =>list.to_json, :layout=>false
  end
end

