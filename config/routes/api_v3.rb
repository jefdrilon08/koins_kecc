namespace :api do
  namespace :v3 do
    post "/users", to: "users#create"
    put "/users/:id", to: "users#update"
  end
end
