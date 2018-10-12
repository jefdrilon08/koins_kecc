namespace :api do
  namespace :v1 do
    # Users
    post "/login", to: "users#login"

    # Members
    get "/members", to: "members#index"
    post "/members/generate_access_token", to: "members#generate_access_token"

    # Member accounts
    get "/savings_accounts", to: "savings_accounts#index"

    # Accounting
    get "/accounting/fetch_trial_balance", to: "accounting#fetch_trial_balance"
    get "/accounting/fetch_general_ledger", to: "accounting#fetch_general_ledger"

    # Loans
    post "/loans/reage", to: "loans#reage"

    # Branches
    get "/branches", to: "branches#index"

    namespace :epassbook do
      get "/members/show", to: "members#show"
    end
  end
end
