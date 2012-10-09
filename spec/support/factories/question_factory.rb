FactoryGirl.define do
  factory :question do
    body "Are you my mommy?"
    type "advice"
    practice_area "Real Estate"
    state_name "Alaska"
    user
  end
end
