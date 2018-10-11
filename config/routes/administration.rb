namespace :administration do
  resources :users, except: [:destroy]
  resources :account_transactions, only: [:show]
  resources :areas
  resources :clusters
  resources :branches
  resources :centers
  resources :announcements
end
