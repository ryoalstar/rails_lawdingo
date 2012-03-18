class Question < ActiveRecord::Base
  attr_accessible :type, :user_id, :body
  belongs_to :user
end
