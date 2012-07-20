class Question < ActiveRecord::Base
  attr_accessible :type, :user_id, :body
  belongs_to :user
  has_one :inquiry

  after_save :create_inquiry

  set_inheritance_column :ruby_type

  private

  def create_inquiry
    Inquiry.create(question_id: self.id)
  end
end
