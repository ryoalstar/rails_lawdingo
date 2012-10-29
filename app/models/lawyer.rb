class Lawyer < User

  # validates :payment_email, :bar_ids, :practice_areas, :presence =>true
  # validates :payment_email, :presence => true
  PAYMENT_STATUSES = ['free', 'paid', 'unpaid']
  STRIPE_PLAN_ID = '5' # 'really_test'
  STRIPE_COUPON_ID = 'dingobaby' # 'xsgdfgvdsf'

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
<<<<<<< HEAD
  attr_accessible :practice_area_ids, :is_available_by_phone, :is_online, :rate, :payment_email, :photo, :personal_tagline, :bar_memberships_attributes, :phone, :time_zone, :hourly_rate
=======
  attr_accessible :practice_area_ids, :is_available_by_phone, :is_online, :rate, :payment_email, :photo, :personal_tagline, 
  :bar_memberships_attributes, :phone, :time_zone, :hourly_rate, :school_id, :undergraduate_school, :license_year, 
  :yelp_business_id

>>>>>>> 0fc80aabbd603f76417fe1f975ea94da477790d1
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
      "<a href='/lawyers#!/lawyers/Legal-Advice/All-States/#{area.name_for_url}'>#{area.name.downcase}</a>"
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

  def save_with_payment stripe_card_token
    if valid?

      #customer = Stripe::Customer.create( description: email, plan: '3', card: stripe_card_token )
      #Stripe error while creating customer: No such plan: 3; a similar object exists in live mode, but a test mode key was used to make this request.
      #Changed by AF 
      
      customer = Stripe::Customer.create( description: email,  card: stripe_card_token )
      
      self.stripe_customer_token = customer.id
      self.stripe_card_token = stripe_card_token
      save!
    end
  rescue Stripe::CardError => e
    logger.error "Stripe error while subscribing customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  end

  def update_payment_status
    result = Stripe::Invoice.all(
      :customer => self.stripe_customer_token,
      :paid => false
    )
    self.update_attribute(:payment_status, :unpaid) if result.count > 0
  end  

  def create_stripe_card attributes
    create_stripe_customer! unless self.stripe_customer_token
    stripe_card_token = Stripe::Token.create(
      :card => {
      :number => attributes[:number],
      :exp_month => attributes[:exp_month],
      :exp_year => attributes[:exp_year],
      :cvc => attributes[:cvc]
    })
    if stripe_card_token.is_a? Stripe::StripeObject
      self.stripe_card_token = stripe_card_token.id 
      add_card_to_customer
      save!
    end
  end

  def create_stripe_test_card!
    self.create_stripe_card(:number => "4242424242424242",:exp_month => 9,:exp_year => 2013,:cvc => 314)
  end

  def create_stripe_customer!
    self.create_stripe_customer
    save!
  end 

  def create_stripe_customer
    customer = Stripe::Customer.create(
      :description => self.email
    )
    if customer.is_a? Stripe::Customer
      self.stripe_customer_token = customer.id
    end
  end  

  def add_card_to_customer
    return false unless self.stripe_card_token
    customer = self.get_stripe_customer
    customer.card = self.stripe_card_token
    customer.save
  end  

  def get_stripe_customer
    return nil unless self.stripe_customer_token
    Stripe::Customer.retrieve(self.stripe_customer_token)
  end   

  def delete_stripe_customer!
    return false unless self.get_stripe_customer
    customer = self.get_stripe_customer
    customer.delete
    self.stripe_customer_token = nil
    self.stripe_card_token = nil
    save!
  end

  def get_stripe_card
    return nil unless self.stripe_card_token
    Stripe::Token.retrieve(self.stripe_card_token)
  end

  def delete_stripe_card!
    return false unless self.stripe_card_token
    self.stripe_card_token = nil
    save!
  end

  def create_stripe_subscribtion stripe_customer, stripe_plan, stripe_card
    customer = Stripe::Subscription.create( description: self.email, plan: STRIPE_PLAN_ID, card: self.stripe_card_token )
      self.stripe_customer_token = customer.id
      self.stripe_card_token = stripe_card_token
      save!
  end

  def cancel_stripe_subscribtion
    customer = self.get_stripe_customer
    return false unless customer
    customer.cancel_subscription
  end

  def self.stripe_create_plan attributes
    Stripe::Plan.create(
      :amount => attributes[:amount],
      :interval => attributes[:interval],
      :name => attributes[:name],
      :currency => attributes[:currency],
      :id => attributes[:id]
    )
  end 

  def self.get_stripe_plan plan_id = STRIPE_PLAN_ID
    Stripe::Plan.retrieve(plan_id)
  end

  def self.delete_stripe_plan plan_id
    plan = Stripe::Plan.retrieve(plan_id)
    plan.delete if plan.is_a? Stripe::Plan
  end

  def subscribe! plan_id = STRIPE_PLAN_ID
    customer = self.get_stripe_customer
    return false unless customer
    customer.update_subscription(:plan => plan_id)
  end  

  def unsubscribe! plan_id = STRIPE_PLAN_ID
    self.cancel_stripe_subscribtion
  end 

  def subscribed? plan_id = STRIPE_PLAN_ID
    customer = self.get_stripe_customer
    return false unless customer
    return false unless defined? customer.subscription
    customer.subscription.plan.id == plan_id
  end  

  def stripe_get_coupon coupon_id = STRIPE_COUPON_ID
    Stripe::Coupon.retrieve(coupon_id)
  end

  def coupon_valid? coupon_id, allow_nil = true
    return true if allow_nil && coupon_id.empty?
    return false if !allow_nil && coupon_id.empty?
    coupon = self.stripe_get_coupon(coupon_id)
    errors.add(:coupon, "That code is invalid.") and return false unless coupon
    true
  rescue Stripe::InvalidRequestError
    errors.add(:coupon, "That code is invalid.") and return false
  end  

  def apply_coupon plan_id = STRIPE_PLAN_ID, coupon_id
    return true if coupon_id.empty? # allow blank coupon
    return false unless coupon_valid?(coupon_id)
    customer = self.get_stripe_customer
    coupon = self.stripe_get_coupon(coupon_id)
    return false unless customer && coupon
    customer.update_subscription(:plan => plan_id, :coupon => coupon.id)
  end

  def coupon_applied? coupon_id = STRIPE_COUPON_ID
    customer = self.get_stripe_customer 
    coupon = self.stripe_get_coupon(coupon_id)
    return false unless customer && coupon
    return false unless defined? customer.discount.coupon
    customer.discount.coupon.id == coupon.id
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
