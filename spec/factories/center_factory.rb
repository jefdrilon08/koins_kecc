FactoryBot.define do
  factory :center do
    branch
    name  { "some_name" }
    short_name { "some_short_name" }
  end
end
