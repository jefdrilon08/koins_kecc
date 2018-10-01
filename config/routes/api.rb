namespace :api do
  namespace :v1 do
    # Users
    post "/login", to: "users#login"

    # Members
    get "/members", to: "members#index"

    # Member accounts
    get "/savings_accounts", to: "savings_accounts#index"
  end
end
