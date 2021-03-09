FactoryBot.define do
  factory :member_account_daily_statement do
    member { nil }
    member_account { nil }
    transacted_at { "2021-03-09" }
    branch { nil }
    debit_amount { "9.99" }
    credit_amount { "9.99" }
  end
end
