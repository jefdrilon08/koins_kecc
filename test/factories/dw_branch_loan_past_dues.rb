FactoryBot.define do
  factory :dw_branch_loan_past_due do
    branch { nil }
    area { nil }
    cluster { nil }
    amount { "9.99" }
    data { "" }
    record_type { "MyString" }
    status { "MyString" }
    month { 1 }
    year { 1 }
  end
end
