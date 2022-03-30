FactoryBot.define do
  factory :dw_branch_loan_product_outstanding_loan_amount do
    branch { nil }
    cluster { nil }
    area { nil }
    status { "MyString" }
    data { "" }
    amount { "9.99" }
    loan_product_category { nil }
  end
end
