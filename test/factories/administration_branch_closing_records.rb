FactoryBot.define do
  factory :administration_branch_closing_record do
    data_store { nil }
    record_type { "MyString" }
    data { "" }
    closing_date { "2022-06-28" }
    branch { nil }
  end
end
