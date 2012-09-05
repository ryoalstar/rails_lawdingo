class Call < ActiveRecord::Base
  belongs_to :client
  belongs_to :conversation

  CALL_STATUS = ['dialing','ignored','connected','billed','disconnected','completed']
  validates_inclusion_of :status, :in => CALL_STATUS, :message => "Invalid call status"

  def update_status(call_status)
    update_attribute(:status, call_status.to_s)
  end

  def billable_time
    billable_time_in_seconds = billing_start_time.present? ? (end_date - billing_start_time) : 0
    (billable_time_in_seconds / 60).ceil
  end
end
