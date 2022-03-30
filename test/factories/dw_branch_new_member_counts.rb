FactoryBot.define do
  factory :dw_branch_new_member_count do
    branch { nil }
    cluster { nil }
    area { nil }
    status { "MyString" }
    data { "" }
    count_male { 1 }
    count_female { 1 }
    total { 1 }
  end
end
