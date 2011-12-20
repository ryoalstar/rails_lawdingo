class PracticeArea < ActiveRecord::Base
  has_many :specialities, :class_name => "PracticeArea", :foreign_key => "parent_id", :dependent => :destroy
  belongs_to :main_area, :class_name => "PracticeArea", :foreign_key => "parent_id"
  has_many :expert_areas
  has_many :lawyers, :through => :expert_areas

  scope :parent_practice_areas, lambda { where(:parent_id => nil) }
  scope :child_practice_areas, lambda { where("parent_id is not null") }

end

