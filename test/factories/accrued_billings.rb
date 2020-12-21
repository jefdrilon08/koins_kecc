FactoryBot.define do
  factory :accrued_billing do
    collection_date { "2020-12-15" }
    data { "" }
    status { "MyString" }
    date_approved { "2020-12-15" }
  end
end
