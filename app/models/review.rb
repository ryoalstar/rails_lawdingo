class Review < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :lawyer
end
