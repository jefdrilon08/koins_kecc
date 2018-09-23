namespace :administration do
  resources :users, except: [:destroy]
  resources :areas
  resources :clusters
  resources :branches
  resources :centers
end
