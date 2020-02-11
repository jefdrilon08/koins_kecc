FactoryBot.define do
  factory :branch do
    cluster
    name  { "some_name" }
    short_name { "some_short_name" }
  end
end
