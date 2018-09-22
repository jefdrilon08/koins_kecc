namespace :administration do
  resources :users, except: [:destroy]
end
