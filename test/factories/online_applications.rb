FactoryBot.define do
  factory :online_application do
    first_name { "MyString" }
    middle_name { "MyString" }
    last_name { "MyString" }
    gender { "MyString" }
    date_of_birth { "2021-05-11" }
    civil_status { "MyString" }
    home_number { "MyString" }
    mobile_number { "MyString" }
    reference_number { "MyString" }
    status { "MyString" }
    place_of_birth { "MyString" }
    religion { "MyString" }
    data { "" }
  end
end
