namespace :api do
  namespace :v1 do
    # Users
    post "/login", to: "users#login"

    # Members
    get "/members", to: "members#index"
  end
end
