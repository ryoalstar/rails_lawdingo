class BarMembership < ActiveRecord::Base
  belongs_to :lawyer
  belongs_to :state
end

