FactoryBot.define do
  factory :user do
    sequence(:email) { Faker::Internet.email }
    sequence(:username) { Faker::Internet.username(specifier: 10) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    identification_number { Faker::Internet.username(specifier: 20) }
    roles { [] }
    encrypted_password { User.new(password: 'password').encrypted_password }
  end
end
