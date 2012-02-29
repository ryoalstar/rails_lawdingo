class PracticeArea < ActiveRecord::Base
  has_many :specialities, :class_name => "PracticeArea", :foreign_key => "parent_id", :dependent => :destroy
  belongs_to :main_area, :class_name => "PracticeArea", :foreign_key => "parent_id"
  has_many :expert_areas
  has_many :lawyers, :through => :expert_areas
  has_many :offerings

  scope :parent_practice_areas, lambda { where(:parent_id => nil) }
  scope :child_practice_areas, lambda { where("parent_id is not null") }
  scope :parent_practice_areas_having_lawyers, joins(:expert_areas, :lawyers).where(:parent_id => nil).select("distinct(practice_areas.id)")
  scope :child_practice_areas_having_lawyers, joins(:expert_areas, :lawyers).where("parent_id is not null").select("distinct(practice_areas.id)")
end

