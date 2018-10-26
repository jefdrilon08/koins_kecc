namespace :api do
  namespace :v1 do
    # Accounting Codes
    get "/accounting_codes", to: "accounting_codes#index"

    # Users
    post "/login", to: "users#login"

    # Members
    get "/members", to: "members#index"
    get "/members/fetch", to: "members#fetch"
    post "/members/generate_access_token", to: "members#generate_access_token"
    post "/members/save_signature", to: "members#save_signature"
    post "/members/save", to: "members#save"

    # Member accounts
    get "/savings_accounts", to: "savings_accounts#index"

    # Accounting
    get "/accounting/fetch_trial_balance", to: "accounting#fetch_trial_balance"
    get "/accounting/fetch_general_ledger", to: "accounting#fetch_general_ledger"

    # Accounting Entries
    get "/accounting_entries/fetch", to: "accounting_entries#fetch"
    post "/accounting_entries/save", to: "accounting_entries#save"
    post "/accounting_entries/approve", to: "accounting_entries#approve"

    # Loans
    post "/loans/reage", to: "loans#reage"

    # Branches
    get "/branches", to: "branches#index"

    namespace :epassbook do
      get "/members/show", to: "members#show"
      get "/active_loans", to: "loans#active_loans"
      get "/savings", to: "savings#index"
      get "/savings/show", to: "savings#transactions"
      get "/equities", to: "equities#index"
      get "/equities/show", to: "equities#transactions"
      get "/loans/show", to: "loans#show"
      get "/loans/payments", to: "loans#payments"
    end
  end
end
