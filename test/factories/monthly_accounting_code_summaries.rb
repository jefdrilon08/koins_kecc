FactoryBot.define do
  factory :monthly_accounting_code_summary do
    month { 1 }
    year { 1 }
    branch { nil }
    accounting_code { nil }
    category { "MyString" }
    dr_amount { "9.99" }
    cr_amount { "9.99" }
  end
end
