class Offering < ActiveRecord::Base
  belongs_to :practice_area
  belongs_to :user
end

