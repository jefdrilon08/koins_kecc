FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "username#{n}" }
    first_name { "some_some_first_name" }
    last_name { "some_some_last_name" }
    password { "password" }
    sequence(:identification_number) { |n| "123-#{n}" }
  end
end
