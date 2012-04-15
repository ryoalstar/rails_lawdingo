class Question < ActiveRecord::Base
  attr_accessible :type, :user_id, :body
  belongs_to :user

  set_inheritance_column :ruby_type
end
