FactoryBot.define do
  factory :member do
    center
    branch
    data { {} }
    gender { "some_gender" }
    date_of_birth { 1.year.ago }
    first_name { "some_first_name" }
    last_name { "some_last_name" }
    civil_status { "some_civil_status" }
  end
end
