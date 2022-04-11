FactoryBot.define do
  factory :dw_branch_member_count do
    branch { nil }
    cluster { nil }
    area { nil }
    status { "MyString" }
    as_of { "2022-03-27" }
    count { 1 }
    data { "" }
  end
end
