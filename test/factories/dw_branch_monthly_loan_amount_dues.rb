FactoryBot.define do
  factory :dw_branch_monthly_loan_amount_due do
    branch { nil }
    area { nil }
    cluster { nil }
    amount { "9.99" }
    data { "" }
    status { "MyString" }
    month { 1 }
    year { 1 }
  end
end
