FactoryBot.define do
  factory :online_application_document do
    file_name { "MyString" }
    data { "" }
    online_application { nil }
  end
end
