FactoryBot.define do
  factory :bank_transfer do
    name { "MyString" }
    amount { "9.99" }
    data { "" }
    accounting_entry_id { "" }
    transfer_options { nil }
  end
end
