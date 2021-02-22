FactoryBot.define do
  factory :accounting_code_balance do
    accounting_code { nil }
    accounting_fund { nil }
    branch { nil }
    start_date { "2021-02-19" }
    end_date { "2021-02-19" }
    total_beginning_debit { "9.99" }
    total_beginning_credit { "9.99" }
    total_current_debit { "9.99" }
    total_current_credit { "9.99" }
    total_ending_debit { "9.99" }
    total_ending_credit { "9.99" }
  end
end
