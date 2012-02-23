class Offering < ActiveRecord::Base
  belongs_to :offering_type
  belongs_to :user

  before_save do |offering|
    case offering.offering_type.id
    when 1 # Contract review
      offering.practice_area_id = 41 # Business
    when 2 # Incorporation
      offering.practice_area_id = 41
    when 3 # Trademark application
      offering.practice_area_id = 41
    when 4 # Will and estate creation
      offering.practice_area_id = 43
    end
  end
end
