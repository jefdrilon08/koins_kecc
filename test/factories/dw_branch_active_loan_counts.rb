FactoryBot.define do
  factory :dw_branch_active_loan_count do
    branch { nil }
    cluster { nil }
    area { nil }
    status { "MyString" }
    as_of { "2022-03-29" }
    data { "" }
    total { 1 }
  end
end
