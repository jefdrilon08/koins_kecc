FactoryBot.define do
  factory :loan do
    center
    branch
    member
    loan_product

    date_prepared { Date.today }

    principal { 1 }
    principal_paid { 1 }
    principal_balance { 1 }

    interest { 1 }
    interest_paid { 1 }
    interest_balance { 1 }
  end
end
