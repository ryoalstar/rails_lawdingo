class Appointment < ActiveRecord::Base

  # Associations
  belongs_to :client, :inverse_of => :appointments
  belongs_to :lawyer, :inverse_of => :appointments
  belongs_to :state, :inverse_of => :appointments
  belongs_to :practice_area, :inverse_of => :appointments

  # Validations

  # REMOVED FOR NOW - WILL COME BACK
  # validates :appointment_type, :inclusion => {
  #   :in => %w{phone video},
  #   :message => "%{value} is not a valid type of appointment"
  # }
  # validates :contact_number, :format => {
  #   :with => /\d{10}/,
  #   :message => "Must be a valid phone number (999) 999 9999",
  #   :if => Proc.new{|record| record.appointment_type == "phone"}
  # }
  validates :client, :presence => true
  validates :lawyer, :presence => true
  validates :time, :presence => true
  scope :futures, where('time >= ?', DateTime.now)
  scope :need_for_initiate, where(:time => (DateTime.now - 1.minute)..(DateTime.now + 1.minute))

  delegate :email,
    :to => :lawyer,
    :prefix => :attorney,
    :allow_nil => true
  
  after_create :send_emails!
  
  def send_emails!
    self.notify_client_about_appointment_created!
    self.notify_lawyer_about_appointment_created!
  end
  
  def notify_client_about_appointment_created!
    return false unless self.client.present?
    return false unless self.client.email.present?
    AppointmentMailer.notify_client_about_appointment_created(self).deliver
  end
  
  def notify_lawyer_about_appointment_created!
    return false unless self.lawyer.present?
    return false unless self.lawyer.email.present?
    AppointmentMailer.notify_lawyer_about_appointment_created(self).deliver
  end

  # full name of this appointment's attorney
  def attorney_name
    return nil if self.lawyer.blank?
    return self.lawyer.full_name
  end

  # full name of this appointment's attorney
  def client_name
    return nil if self.client.blank?
    return self.client.full_name
  end

  # standardize format of contact number
  def contact_number
    num = read_attribute(:contact_number)
    return "" if num.blank?
    return "(#{num[0..2]}) #{num[3..5]}-#{num[6..9]}"
  end
  
  # setter for contact_number - remove all non-digit characters
  def contact_number=(new_number)
    write_attribute(:contact_number, new_number.gsub(/[^\d]/,''))
  end

  # number of free minutes for this appt
  def free_minutes
    return nil if self.lawyer.blank?
    return self.lawyer.free_consultation_duration
  end

  # per-minute rate for this appt
  def per_minute_rate
    return nil if self.lawyer.blank?
    return self.lawyer.rate
  end
  
  def client_call_to_lawyer
    return false unless self.client.is_a? Client
    return false unless self.lawyer.is_a? Lawyer
    self.client.call_to_lawyer self.lawyer
  end

end
