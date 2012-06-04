include ActionView::Helpers::NumberHelper # Number helpers available inside controller method

class SearchController < ApplicationController
  include LawyersHelper
  
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
    
    @type = type.to_s

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

      @state_lawyers.each do |lawyer|
        if lawyer.offerings.any?
          lawyer.offerings.each do |offering|
            @state_offerings << offering
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
      else
        @area_offerings = Offering.all
      end

      @offerings = @area_offerings & @state_offerings
        
      render action: "filter_offering_results", layout: false
    end
  end

  # <sarcasm> skinny controller, fat model? Yeah! </sarcasm>
  # templates? Newer hear...
  def get_homepage_lawyers
     homepage_images = HomepageImage.all
     list = []
     practice_area_text = ""
     homepage_images.each do |image|
       lawyer = image.lawyer
       practice_area_text = "Advising on #{lawyer.practice_areas_listing} law. " unless lawyer.parent_practice_area_string.empty?
       images_hash = Hash.new
       images_hash["url"] = image.photo.url(:large)
       images_hash["title"] = "<a href='/attorneys/#{lawyer.id}/#{lawyer.slug}'>#{lawyer.full_name}</a>".html_safe
       images_hash["description"] = practice_area_text + "#{lawyer.free_consultation_duration} minutes free consultation, then #{number_to_currency (lawyer.rate + AppParameter.service_charge_value)}/minute."
       images_hash["small"]="then #{number_to_currency (lawyer.rate + AppParameter.service_charge_value)}/minute"
       images_hash["rate"]="#{lawyer.free_consultation_duration} minutes free"
       star=[]  
       star[1]='off'
       star[2]='off'
       star[3]='off'
       star[4]='off'
       star[5]='off'
       a=lawyer.reviews.average(:rating).to_i
       a.times do |i|
         star[i+1]='on'
       end   
       if a != 0
         images_hash["rating"] = "<img src='/assets/raty/star-#{star[1]}.png' alt='1' title='not rated yet'>&nbsp;<img src='/assets/raty/star-#{star[2]}.png' alt='2' title='not rated yet'>&nbsp;<img src='/assets/raty/star-#{star[3]}.png' alt='3' title='not rated yet'>&nbsp;<img src='/assets/raty/star-#{star[4]}.png' alt='4' title='not rated yet'>&nbsp;<img src='/assets/raty/star-#{star[5]}.png' alt='5' title='not rated yet'>"
       else
         images_hash["rating"] = ""
       end
       images_hash["test"] = lawyer.reviews.count
       if (lawyer.yelp_business_id.present? && !!lawyer.yelp[:reviews]) || lawyer.reviews.count.to_i > 0
         if lawyer.yelp_business_id.present? && !!lawyer.yelp[:reviews]
           puts lawyer.yelp[:review_count].inspect
           images_hash["reviews"] = "#{lawyer.yelp[:review_count]} <a href='http://www.yelp.com'><img src='/assets/miniMapLogo.png' /></a> reviews".html_safe
           images_hash["link_reviews"] = "<a href='/attorneys/#{lawyer.id}/#{CGI::escape(lawyer.full_name)}#reviews' class = 'yelp_reviews'><span class = 'number_rev'></span></a>"
           images_hash["rating"] = "<img src='#{lawyer.yelp[:rating_img_url]}' />"
         else
           images_hash["reviews"] = "#{lawyer.reviews.count} reviews"
           images_hash["link_reviews"] = "<a href='/attorneys/#{lawyer.id}/#{CGI::escape(lawyer.full_name)}#reviews' class = 'reviews'><span class = 'number_rev'></span></a>"
         end
       end
       images_hash["href"] = attorney_path(lawyer, slug: lawyer.slug)
       images_hash["start_video_conversation"] = start_or_schedule_button(lawyer) if lawyer.is_online && !lawyer.is_busy
       images_hash["start_phone_conversation"] = start_phone_consultation(lawyer) if lawyer.phone.present? 
       images_hash["start_or_video_button_p"] = start_or_video_button_p(lawyer) if lawyer.is_online
       images_hash["start_phone_consultation_p"] = start_phone_consultation_p(lawyer) if lawyer.phone.present? 
       images_hash["send_text_question"]       = start_or_schedule_button_text(lawyer)
       images_hash["start_or_schedule_button_text_profile"] = start_or_schedule_button_text_profile(lawyer)
         
       list << images_hash
     end
     render :text => list.to_json, :layout=>false
  end
  
  protected
  
  def link_to(*args)
    puts args.inspect
    self.class.helpers.link_to *args
  end
end

