class Call < ActiveRecord::Base
  belongs_to :client

  CALL_STATUS =['dialing','rejected','billed','connected','completed']
  validates_inclusion_of :status, :in => CALL_STATUS, :message => "Invalid call status"
end

