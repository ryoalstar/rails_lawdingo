FactoryGirl.define do
  factory :lawyer do
    first_name "Dan"
    last_name "Langevin"
    email "dan.langevin@gmail.com"
    password "123456"
    user_type User::LAWYER_TYPE
    free_consultation_duration 10
    is_approved true
    time_zone "Pacific Time (US & Canada)"
  end
end
