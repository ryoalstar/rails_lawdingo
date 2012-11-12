class Lawyer < User
  include Extensions::VStripe
  
  PAYMENT_STATUSES = ['free', 'paid', 'unpaid']

  has_many :bar_memberships, :inverse_of => :lawyer
  has_many :conversations
  has_many :bids
  has_many :messages
  has_many :appointments
  has_many :expert_areas
  has_many :practice_areas, :through => :expert_areas
  has_many :reviews
  has_many :states, :through => :bar_memberships
  has_one :homepage_image, :dependent => :destroy
  has_many :daily_hours, :autosave => true 

  def reindex!
     Sunspot.index!(self)
  end

  # validations
  validates_presence_of :payment_status, :if => :is_lawyer?
  validates_inclusion_of :payment_status, :in => PAYMENT_STATUSES, :if => :is_lawyer?
  validates :time_zone,
    :presence => true

  # TODO: use attr_accessible
  #attr_accessible :payment_status, :stripe_customer_token, :stripe_card_token
  
  accepts_nested_attributes_for :bar_memberships, :reject_if => proc { |attributes| attributes['state_id'].blank? }
  attr_accessible :practice_area_ids, :is_available_by_phone, :is_online, :rate, :payment_email, :photo, :personal_tagline, 
  :bar_memberships_attributes, :phone, :time_zone, :hourly_rate, :school_id, :undergraduate_school, :license_year, 
  :yelp_business_id, :payment_status

  # scopes
  default_scope lambda{
    where(:user_type => User::LAWYER_TYPE)
  }

  scope :approved_lawyers, lambda{
    where(:is_approved => true)
      .order("is_online desc, phone desc")
  }

  scope :offers_legal_services, lambda{
    includes(:offerings)
      .where("offerings.id IS NOT NULL")
  }

  scope :offers_legal_advice, lambda{
    includes(:practice_areas)
      .where("practice_areas.id IS NOT NULL")
  }

  scope :practices_in_state, lambda{|state_or_name|
    name = state_or_name.is_a?(State) ? state_or_name.name : state_or_name
    includes(:states)
      .where(["states.name = ?", name])
  }

  scope :paid, lambda{
    where('stripe_card_token IS NOT NULL')
      .where('stripe_customer_token IS NOT NULL')
      .where(:payment_status => 'paid')
  }
  scope :unpaid, lambda{
    where(:payment_status => 'unpaid')
  }
  scope :free, lambda{
    where(:payment_status => 'free')
  }
  scope :shown, lambda{
    where(:is_approved => true).where(:payment_status => ['paid', 'free']) 
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

  #solr index
  searchable :auto_index => true, :auto_remove => true, :if => proc { |lawyer| lawyer.user_type == User::LAWYER_TYPE && lawyer.is_approved} do
    text :flat_fee_service_name do
      offering_names if offerings!=[]
    end
    text :flat_fee_service_description do
      offering_descriptions if offerings!=[]
    end
    text :practice_areas do
       practice_area_names
    end
    integer :practice_area_ids, :multiple => true
    text :personal_tagline
    text :first_name
    text :last_name
    text :law_school
    text :states do
      state_names
    end
    text :state_abbreviations
    integer :state_ids, :multiple => true
    text :reviews do
      review_purpos
    end
    text :school do
      school.name if school.present?
    end
    string :bar_memberships, :multiple => true
    string :payment_status
    integer :free_consultation_duration
    float :rate
    integer :lawyer_star_rating do
      reviews.average(:rating).to_i
    end
    integer :school_rank do
      school.rank_category if !!school
    end
    time :created_at
    boolean :is_approved
    boolean :is_online
    boolean :available_by_phone do
      self.is_available_by_phone?
    end  
    boolean :daily_hours_present do
      self.daily_hours.present?
    end   
    integer :calculated_order
  end

  def calculated_order
    calculated_score = 0
    calculated_score += 100 if self.is_online
    calculated_score += 10 if self.daily_hours.present?
    calculated_score += 1 if self.is_available_by_phone?
    calculated_score
  end
  
  def rate_for_minutes(minutes)
    (self.rate * minutes *100).round()/100
  end  
  
  def hourly_rate
    self.rate.nil? ? '' : self.rate* 60
  end
  
  def hourly_rate=(value)
    self.rate = value.to_f / 60.0
  end

  def detail
    super.merge(
      "Rate" =>"$ #{rate}/minute",
      "Tag Line" =>self.personal_tagline,
      "Address" => self.address,
      "Practice Areas" =>self.practice_areas,
      "Law School" => self.law_school,
      "Bar memberships"=>self.bar_memberships
    )
  end

  def offering_names
    offerings.map(&:name)*","
  end

  def offering_descriptions
    offerings.map(&:description)*","
  end

  def practice_area_names
    self.practice_areas.map(&:name)*","
  end

  def state_names
    states.map(&:name)*","
  end
  
  def state_abbreviations
    states.map(&:abbreviation)*","
  end

  def review_purpos
    reviews.map(&:purpose)*","
  end

  def self.build_search(query, opts = {})
    search = self.search(
      :include => [
        {:bar_memberships => :state},
        {:practice_areas => :expert_areas},
        :offerings, :daily_hours, :reviews
      ],
    )
    search.build do
      fulltext query
      paginate :per_page => 20, :page => opts[:page] || 1
      order_by :calculated_order, :desc
      order_by :created_at, :desc
      with :is_approved, true
      with :payment_status, [:paid, :free]
    end
    search
  end

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

  def is_available_by_phone?
    return false unless self.is_available_by_phone
    # if we haven't set hours, default to true
    return true if self.daily_hours.blank?
    # check normal bookability
    return self.bookable_at_time?(Time.zone.now)
  end

  # all available times for a given date
  def available_times(time)
    self.in_time_zone do
      # make sure it's a time
      time = self.convert_date(time)
      # get the relevant daily_hour
      daily_hour = self.daily_hours_on_wday(time.wday)
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
  
  # are we bookable at a given time?
  def bookable_at_time?(time)
    self.in_time_zone do
      dh = self.daily_hours_on_wday(time.wday)
      return false if dh.blank?
      return dh.bookable_at_time?(time) rescue false
    end
  end

  # is this provider bookable on a given date
  def bookable_on_day?(date)
    self.in_time_zone do
      dh = self.daily_hours_on_wday(date.wday)
      return false if dh.blank?
      return dh.bookable_on_day?(date)
    end
  end
  
  # is this provider bookable on a given date
  def bookable_on_day_ontimezone?(date, timezone)
    self.in_specific_time_zone(timezone) do
      dh = self.daily_hours_on_wday(date.wday)
      return false if dh.blank?
      return dh.bookable_on_day?(date)
    end
  end

  # find the daily hours for a particular wday
  def daily_hours_on_wday(wday)
    self.daily_hours.select{|dh| dh.wday == wday}.first
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
  
  def in_specific_time_zone(timezone, &block)
    begin
      old_zone = Time.zone
      Time.zone = timezone
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
          max_time = Time.zone.now.midnight + (num_days).weeks
          # go until we have enough days to return
          while ret.length < num_days && t <= max_time
            # if we have this day
            if self.bookable_on_day?(t)
              ret << t.to_date
            end
            # 25 hours to account for daylight savings
            t = t + 24.hours
          end
        end
      end
    end
  end
  
  # the next x days on which the lawyer is open
  def next_available_days_usertimezone(num_days)
    return [] if self.daily_hours.blank?
    [].tap do |ret|
      # start on today

      t = Time.zone.now.midnight
      max_time = Time.zone.now.midnight + (num_days).weeks
      # go until we have enough days to return
      while ret.length < num_days && t <= max_time
        # if we have this day
        if self.bookable_on_day_ontimezone?(t, Time.zone)
          ret << t.to_date
        end
        # 25 hours to account for daylight savings
        t = t + 24.hours
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
      #area.name.downcase
      "<a href='/lawyers/Legal-Advice/All-States/#{area.name_for_url}' class='practice_area_name' data-practice-area='#{area.name_for_url}'>#{area.name.downcase}</a>"
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
      states << membership.state.abbreviation if membership.state.present?
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
  
  def owner? thing
    case thing.class.to_s
    when 'Message'
      return false unless thing.lawyer_id
      return true if self.id.eql?(thing.lawyer_id)
     when 'Question' 
      return false unless thing.user_id
      return true if self.id.eql?(thing.user_id)
    end
    false
  end

end
