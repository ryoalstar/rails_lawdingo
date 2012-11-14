class Client < User
  include Extensions::VStripe
  include Rails.application.routes.url_helpers

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
  
  def call_to_lawyer lawyer
    return false unless lawyer.is_a? Lawyer
    return false unless self.persisted?
    return false unless self.phone.present?
    return false unless lawyer.phone.present?
    return false unless self.stripe_customer_token.present?
    
    client = Twilio::REST::Client.new(Twilio::ACCOUNT_SID, Twilio::AUTH_TOKEN)

    call = client.account.calls.create(
      from: Twilio::FROM,
      to: self.phone,
      url: twilio_welcome_url(
        lawyer_rate: lawyer.rate,
        lawyer_number: lawyer.phone,
        client_number: self.phone,
        duration_for_free: lawyer.free_consultation_duration
      ),
      fallbackurl: twilio_fallback_url,
      statuscallback: twilio_callback_url
    )

    Call.create(:client_id => self.id, :lawyer_id => lawyer.id, :from => self.phone,:to => lawyer.phone, :sid => call.sid, :status => "dialing", :start_date => Time.now)
  end

end

