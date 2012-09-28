class Message < ActiveRecord::Base
  belongs_to :client
  belongs_to :lawyer
  validates :client, :lawyer, :body, :presence => true

  def send!
    self.save unless self.persisted? && self.valid?
    UserMailer.schedule_session_email(client, lawyer.email, body).deliver
  end  
end