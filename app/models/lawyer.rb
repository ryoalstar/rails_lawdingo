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
  end
  
  def practice_area_names
    self.practice_areas.map(&:name)*","
  end
  
  def offerings_name
    self.offerings.map(&:name)*","
  end
  
  def offerings_description
    self.offerings.map(&:description)*","
  end
  
  def offerings_practice_area 
    offerings_practice_area_arr=""   
    self.offerings(:include => [:practice_area]).each do |f|
        temp_name=f.practice_area.name+","
        offerings_practice_area_arr=offerings_practice_area_arr+temp_name
    end
    offerings_practice_area_arr
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
  
  
end
