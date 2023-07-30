namespace :api do
  namespace :v3 do
    post "/users", to: "users#create"
  end
end
