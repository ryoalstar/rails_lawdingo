include ActionView::Helpers::NumberHelper # Number helpers available inside controller method

class SearchController < ApplicationController
  def populate_specialities
    @practice_area = PracticeArea.find(params[:pid])
    specialities_ids_lawyers = PracticeArea.child_practice_areas_having_lawyers.map(&:id)
    practice_area_specialites_ids = @practice_area.specialities.map(&:id)
    practice_area_specialites_lawyers_ids = specialities_ids_lawyers & practice_area_specialites_ids
    @practice_area_specialities = PracticeArea.find(practice_area_specialites_lawyers_ids).sort_by(&:name) rescue[]
#    @practice_area_specialities = @practice_area.specialities.order(:name) rescue []
    render :action => 'populate_specialities', :layout => false
  end

  # Temporary method for the next home page
  def populate_specialities_next
    @practice_area = PracticeArea.find(params[:pid])
    @practice_area_specialities = @practice_area.specialities.order(:name) rescue []
    render :action => 'populate_specialities_next', :layout => false
  end

  def filter_results
    type = params[:type]
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

    if type == "lawyer"
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
      render action: "filter_lawyer_results", layout: false
    elsif type == "offering"
      # If all types selected show all fixed-price offers
      @offerings = []
      @state_offerings = []
      @area_offerings = []

      unless state_id == 0
        @state_lawyers.each do |lawyer|
          if lawyer.offerings.any?
            lawyer.offerings.each do |offering|
              @state_offerings << offering
            end
          end
        end
      end

      unless pa_id == 0
        @offerings_practice_area = PracticeArea.find(pa_id)

        if @offerings_practice_area.present?
          @offerings_practice_area.offerings.each do |offering|
            if offering.user.is_approved
              @area_offerings << offering
            end
          end
        end
      end

      if @state_offerings.any? && @area_offerings.any?
        @offerings = @area_offerings & @state_offerings
      elsif @state_offerings.any?
        @offerings = @state_offerings
      elsif @area_offerings.any?
        @offerings = @area_offerings
      else
        @offerings = Offering.all
      end

      render action: "filter_offering_results", layout: false
    end
  end

  def get_homepage_lawyers
     homepage_images = HomepageImage.all
     list = []
     practice_area_text = ""
     homepage_images.each{|image|
     lawyer = image.lawyer
     practice_area_text = "Advising on #{lawyer.practice_areas_listing} law. " unless lawyer.parent_practice_area_string.empty?
     images_hash = Hash.new
     images_hash["url"] = image.photo.url(:large)
     images_hash["title"] = "<a href='/attorneys/#{lawyer.id}/#{lawyer.slug}'>#{lawyer.full_name}</a>".html_safe
     images_hash["description"] = practice_area_text + "#{lawyer.free_consultation_duration} minutes free consultation, then #{number_to_currency (lawyer.rate + AppParameter.service_charge_value)}/minute."
     list << images_hash
     }
     render :text => list.to_json, :layout=>false
  end
end

