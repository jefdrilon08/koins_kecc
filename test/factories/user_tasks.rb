FactoryBot.define do
  factory :user_task do
    user { nil }
    status { "MyString" }
    task_type { "MyString" }
    data { "" }
  end
end
