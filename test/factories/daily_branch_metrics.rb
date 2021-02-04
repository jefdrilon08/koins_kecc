FactoryBot.define do
  factory :daily_branch_metric do
    portfolio { "9.99" }
    past_due_amount { "9.99" }
    as_of { "2021-02-03" }
    par_amount { "9.99" }
    repayment_rate { "9.99" }
    data { "" }
    branch { nil }
  end
end
