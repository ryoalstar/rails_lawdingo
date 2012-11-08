FactoryGirl.define do
  factory :message do
    body { Faker::Lorem.sentence(6)}
    association :client
    association :lawyer
    association :state
    association :practice_area
  end
end
