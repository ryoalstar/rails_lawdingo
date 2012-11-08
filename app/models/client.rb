class Client < User
  include Extensions::VStripe

  # Associations
  has_many :appointments
  has_many :conversations
  has_many :calls
  has_many :messages

  def total_spending
    self.conversations.sum(:billed_amount)
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

  def has_payment_info?
    !self.card_detail.blank?
  end
  
  def owner? thing
    case thing.class.to_s
    when 'Message'
      return false unless thing.client_id
      return true if self.id.eql?(thing.client_id)
     when 'Question' 
      return false unless thing.user_id
      return true if self.id.eql?(thing.user_id)
    end
    false
  end

end

