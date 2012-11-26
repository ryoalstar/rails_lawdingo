FactoryGirl.define do
  factory :answer do
    body "This is my answer"
    association :question
    user
  end
end
