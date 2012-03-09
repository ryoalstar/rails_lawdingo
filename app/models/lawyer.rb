class Lawyer < User
  # validates :payment_email, :bar_ids, :practice_areas, :presence =>true
  # validates :payment_email, :presence => true

  has_many :conversations
  has_many :reviews
  has_many :bar_memberships
  has_many :states, :through => :bar_memberships
  has_many :expert_areas
  has_many :practice_areas, :through => :expert_areas
  has_one :homepage_image, :dependent => :destroy

  accepts_nested_attributes_for :bar_memberships, :reject_if => proc { |attributes| attributes['state_id'].blank? }

  scope :approved_lawyers, where(:user_type => User::LAWYER_TYPE, :is_approved => true).order("is_online desc, phone desc")

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

