FactoryGirl.define do
  factory :user do
    first_name "Thome"
    last_name "York"
    email "user@lawdingo.com"
    password "secret"
    user_type User::CLIENT_TYPE
  end
end
