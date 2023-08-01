namespace :api do
  namespace :v3 do
    post "/users", to: "users#create"
    put "/users/:id", to: "users#update"
    get "/users/:id", to: "users#show"
    delete "/users/:id", to: "users#delete"
  end
end
