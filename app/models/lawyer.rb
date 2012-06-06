class Lawyer < User

  # validates :payment_email, :bar_ids, :practice_areas, :presence =>true
  # validates :payment_email, :presence => true
  
  has_many :bar_memberships
  has_many :conversations

  has_many :daily_hours do
    # find on a given wday
    def on_wday(wday)
      self.select{|dh| dh.wday == wday}.first    
    end
    # are we bookable on a given day?
    def bookable_on_day?(time)
      # allow for dates or times to be passed in
      time = time.to_time if time.is_a?(Date)
      time = time.midnight
      dh = self.on_wday(time.wday)
      return false if dh.blank?
      # if it is the current day, check to see that 
      # it is not too late in the day to book
      if Time.zone.now.midnight == time
        return false if Time.zone.now + 1.hour > dh.end_time_on_date(time)
      end
      return true
    end
  end
  
  #solr index
  searchable :if => proc { |lawyer| lawyer.user_type == User::LAWYER_TYPE && lawyer.is_approved} do
   text :practice_areas do
     practice_area_names
   end
   text :personal_tagline
   text :first_name
   text :last_name
   text :law_school
   text :states do
     state_names
   end
   text :reviews do
     review_purpos
   end
   text :school do
     school.name if school.present?
   end
   string :bar_memberships, :multiple => true
   integer :free_consultation_duration 
   integer :lawyer_star_rating do
     reviews.average(:rating).to_i
   end 
  end
  
  def practice_area_names
    self.practice_areas.map(&:name)*","
  end
  
  
  def state_names
     states.map(&:name)*","
  end
 
   
  def review_purpos
      reviews.map(&:purpose)*","
  end

  def reindex!
     Sunspot.index!(self)
  end
  
  def self.build_search(query)
    search = Sunspot.new_search(Lawyer)
    search.build do
      fulltext query
    end
    search    
  end
  
  has_many :expert_areas
  has_many :practice_areas, :through => :expert_areas
  has_many :reviews
  has_many :states, :through => :bar_memberships
  
  has_one :homepage_image, :dependent => :destroy

  # validations
  validates :time_zone, 
    :presence => true,
    :inclusion => {
      :in => ActiveSupport::TimeZone.us_zones.collect(&:name)
    }

  accepts_nested_attributes_for :bar_memberships, :reject_if => proc { |attributes| attributes['state_id'].blank? }

  scope :approved_lawyers, 
    where(:user_type => User::LAWYER_TYPE, :is_approved => true)
      .order("is_online desc, phone desc")

  scope :offers_legal_services,
    includes(:offerings)
      .where("offerings.id IS NOT NULL")

  scope :offers_legal_advice,
    includes(:practice_areas)
      .where("practice_areas.id IS NOT NULL")

  scope :practices_in_state, lambda{|state_or_name|
    name = state_or_name.is_a?(State) ? state_or_name.name : state_or_name
    includes(:states)
      .where(["states.name = ?", name])
  }

  scope :offers_practice_area, lambda{|practice_area_or_name|
    if practice_area_or_name.is_a?(PracticeArea)
      pa = practice_area_or_name
    else
      pa = PracticeArea.name_like(practice_area_or_name).first 
      pa ||= PracticeArea.new
    end
    includes(:offerings, :practice_areas)
      .where([
        "practice_areas.id IN (:ids) " + 
        "OR offerings.practice_area_id IN (:ids)",
        {:ids => [pa.id] + pa.children.collect(&:id)}
      ])
  }
  
  def self.approved_lawyers_states
    states = []

    approved_lawyers.each do |lawyer|
      states << lawyer.states
    end

   return states[0]
  end

  # returns currently online lawyer user
  def self.online
   self.where('is_online is true' )
  end
  # all available times for a given date
  def available_times(time)
    self.in_time_zone do
      # make sure it's a time
      time = self.convert_date(time)
      # get the relevant daily_hour
      daily_hour = self.daily_hours.on_wday(time.wday)
      return [] if daily_hour.blank?
      # cache the min time to book
      min_time = self.min_time_to_book
      # iterate through the daily hours
      return [].tap do |ret|
        current_time = daily_hour.start_time_on_date(time)
        end_time = daily_hour.end_time_on_date(time)
        while current_time < end_time
          # make sure this is an allowable time and add it
          ret << current_time if current_time >= min_time
          current_time += 30.minutes
        end
      end
    end
  end
  # is this provider bookable on a given date
  def bookable_on_day?(date)
    self.in_time_zone do
      self.daily_hours.bookable_on_day?(date)
    end
  end
  # runs a block in this Lawyer's time_zone
  def in_time_zone(&block)
    begin
      old_zone = Time.zone
      Time.zone = self.time_zone
      yield
    ensure
      Time.zone = old_zone
    end
  end

  # the next x days on which the lawyer is open
  def next_available_days(num_days)
    self.in_time_zone do
      return [] if self.daily_hours.blank?
      self.in_time_zone do
        [].tap do |ret|
          # start on today
          t = Time.zone.now.midnight
          # go until we have enough days to return
          while ret.length < num_days
            # if we have this day
            if self.bookable_on_day?(t)
              ret << t.to_date
            end
            # 25 hours to account for daylight savings
            t = (t + 25.hours).midnight
          end
        end
      end
    end
  end

  def total_earning
    sum = 0.0
    self.conversations.map{|con| sum += con.lawyer_earning }
    sum
  end

  # in seconds
  def total_session_duration
    total_duration = 0
    self.conversations.map{|con| total_duration += con.duration }
    total_duration
  end

  # in seconds
  def total_paid_duration
    total_duration = 0
    self.conversations.map{|con| total_duration += con.billed_time }
    total_duration
  end

  def practice_areas_names
    self.practice_areas.parent_practice_areas.map do |area|
      area.name.downcase
    end
  end

  def practice_areas_listing
    area_names = self.practice_areas_names
    last_area_name = area_names.pop
    area_names.empty? ? last_area_name : "#{area_names.join(', ')} and #{last_area_name}"
  end

  def parent_practice_area_string
    ppa = self.practice_areas.parent_practice_areas.map{|p| p.name}
    ppa.join(',')
  end

  def slug
    "#{full_name.parameterize}"
  end

  def licenced_states
    states = []
    bar_memberships.each do |membership|
      states << membership.state.abbreviation
    end
    states
  end

  def areas_human_list
    pas = []
    pas = practice_areas.parent_practice_areas unless practice_areas.blank?
    pas_string = ""
    pas.each{|pa|
      pas_string += pa.name + ', '
    }
    pas_string.chomp!(', ')

    pas_names = pas.map { |area| area.name.downcase  }
    pas_names_last = pas_names.pop
    pas_names_list = pas_names.empty? ? pas_names_last : "#{pas_names.join(', ')} and #{pas_names_last} law"
  end

  protected
  # convert a date to a time if applicable
  def convert_date(time)
    time = time.to_time if time.is_a?(Date)
    time = time.midnight
    time
  end
  # the earliest time we allow bookings
  def min_time_to_book
    Time.zone.now + 30.minutes
  end
end
