FactoryBot.define do
  factory :make_payment do
    member { nil }
    transaction_date { "2021-11-12" }
    date_approve { "2021-11-12" }
    approved_by { "MyString" }
    created_by { "MyString" }
    data { "" }
    status { "MyString" }
  end
end
