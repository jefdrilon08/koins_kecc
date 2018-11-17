namespace :administration do
  resources :users, except: [:destroy]
  resources :account_transactions, only: [:show]
  resources :areas
  resources :clusters
  resources :branches
  resources :centers
  resources :announcements
  resources :loan_products, only: [:index]

  resources :surveys, only: [:index, :show] do
    get "/form", to: "surveys#form"
  end
end
