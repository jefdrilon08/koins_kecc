FactoryBot.define do
  factory :dw_branch_loan_product_active_loan_count do
    branch { nil }
    cluster { nil }
    area { nil }
    status { "MyString" }
    as_of { "2022-03-29" }
    data { "" }
    total { 1 }
    loan_product { nil }
    loan_product_category { nil }
  end
end
