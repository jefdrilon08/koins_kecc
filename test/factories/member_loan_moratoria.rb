FactoryBot.define do
  factory :member_loan_moratorium do
    member_moratorium { nil }
    loan { nil }
    status { "MyString" }
    data { "" }
  end
end
