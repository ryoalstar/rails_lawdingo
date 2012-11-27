class Question < ActiveRecord::Base
  include ActionView::Helpers
  attr_accessible :type, :user_id, :body, :state_name, :practice_area, :published
  belongs_to :user
  has_one :inquiry
  validates_format_of :body, :with => /^[\w\s.,?!]+$/, :allow_blank => true
  before_save :clear_body
  after_create :create_inquiry

  set_inheritance_column :ruby_type

  def clear_body
    self.body = strip_tags(self.body) if self.body
  end

  def matched_lawyers
    state = State.where(name: self.state_name).first
    practice_area = PracticeArea.where(name: self.practice_area, parent_id: nil).first

    if state or practice_area
     search = Lawyer.search do
       with(:state_ids, state.id) if state.present?
       with(:practice_area_ids, practice_area.id) if practice_area.present?
     end

     search.results
    else
      # Return empty array when state and practice area aren't specified
      # so the question.matched_lawyers.count will return 0 in
      # matched_lawyer_count helper
      []
    end
  end

  private

  def create_inquiry
    Inquiry.create(question_id: self.id)
  end
end
