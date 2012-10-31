class Message < ActiveRecord::Base
  STATUSES = [:new, :paid, :sent, :answered, :not_satisfied]
  belongs_to :client
  belongs_to :lawyer
  belongs_to :state, :inverse_of => :messages
  belongs_to :practice_area, :inverse_of => :messages
  validates :body, :lawyer, :status, :presence => true
  validates :client, :presence => true, :on => :update

  def send!
    self.save unless self.persisted? && self.valid?
    self.update_attribute(:status,STATUSES[2]) if UserMailer.schedule_session_email(client, lawyer.email, body).deliver
  end
end
