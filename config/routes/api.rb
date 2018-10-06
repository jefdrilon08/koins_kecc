namespace :api do
  namespace :v1 do
    # Users
    post "/login", to: "users#login"

    # Members
    get "/members", to: "members#index"

    # Member accounts
    get "/savings_accounts", to: "savings_accounts#index"

    # Accounting
    get "/accounting/fetch_trial_balance", to: "accounting#fetch_trial_balance"
    get "/accounting/fetch_general_ledger", to: "accounting#fetch_general_ledger"
  end
end
