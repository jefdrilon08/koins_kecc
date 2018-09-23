namespace :api do
  namespace :v1 do
    # Users
    post "/login", to: "users#login"
  end
end
