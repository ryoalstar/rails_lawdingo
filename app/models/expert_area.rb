class ExpertArea < ActiveRecord::Base
  belongs_to :lawyer
  belongs_to :practice_area
end

