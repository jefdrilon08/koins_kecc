namespace :api do
  namespace :v3 do
    # User Management
    post "/users", to: "users#create"
    put "/users/:id", to: "users#update"
    get "/users/:id", to: "users#show"
    delete "/users/:id", to: "users#delete"
    get "/users", to: "users#index"

    # User Branch Toggle
    post "/user_branches/toggle"
  end
end
