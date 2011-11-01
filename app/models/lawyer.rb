class Lawyer < User
  validates :payment_email, :bar_ids, :practice_areas, :presence =>true  
  
  has_many :conversations

  # returns currently online lawyer user
  def self.online
   self.where('is_online is true' )
  end

  def self.home_page_lawyers
    self.where("user_type = '#{User::LAWYER_TYPE}' and is_approved is true")
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

end