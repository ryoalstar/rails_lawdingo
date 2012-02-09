class Offering < ActiveRecord::Base
  belongs_to :offering_type
  belongs_to :user
end
