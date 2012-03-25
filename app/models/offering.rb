class Offering < ActiveRecord::Base
  belongs_to :practice_area,
    :touch => true
  belongs_to :user,
    :touch => true
end

