FactoryBot.define do
  factory :loan_product do
    name { "Loan Product ##{SecureRandom.uuid}" }
    min_loan_amount { 10 }
    max_loan_amount { 10 }
    monthly_interest_rate { 1 }
  end
end
