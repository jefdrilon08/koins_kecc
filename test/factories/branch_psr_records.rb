FactoryBot.define do
  factory :branch_psr_record do
    branch { nil }
    closing_date { "2022-08-03" }
    closing_year { 1 }
    closing_month { 1 }
    data { "" }
    status { "MyString" }
  end
end
