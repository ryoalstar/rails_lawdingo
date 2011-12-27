class Lawyer < User
  #validates :payment_email, :bar_ids, :practice_areas, :presence =>true
  validates :payment_email, :presence =>true

  has_many :conversations
  has_many :bar_memberships
  has_many :states, :through => :bar_memberships
  has_many :expert_areas
  has_many :practice_areas, :through => :expert_areas

  accepts_nested_attributes_for :bar_memberships, :reject_if => proc { |attributes| attributes['state_id'].blank? }

  scope :approved_lawyers, lambda { where("user_type = '#{User::LAWYER_TYPE}' and is_approved is true").order("is_online desc") }

  # returns currently online lawyer user
  def self.online
   self.where('is_online is true' )
  end

  #def self.approved_lawyers
   # self.where("user_type = '#{User::LAWYER_TYPE}' and is_approved is true").order("is_online desc")
  #end

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
end

