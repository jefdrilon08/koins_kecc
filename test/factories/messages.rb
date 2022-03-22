FactoryBot.define do
  factory :message do
    topic { "MyString" }
    content { "MyText" }
    member { nil }
    status { "MyString" }
    message { nil }
    data { "" }
  end
end
