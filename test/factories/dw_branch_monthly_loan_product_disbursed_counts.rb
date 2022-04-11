FactoryBot.define do
  factory :dw_branch_monthly_loan_product_disbursed_count do
    branch { nil }
    area { nil }
    cluster { nil }
    loan_product { nil }
    loan_product_category { nil }
    month { 1 }
    year { 1 }
    status { "MyString" }
    total { 1 }
    data { "" }
  end
end
