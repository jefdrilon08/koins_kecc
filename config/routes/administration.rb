namespace :administration do
  resources :users, except: [:destroy]
  resources :account_transactions, only: [:show]
  resources :areas
  resources :clusters
  resources :branches
  resources :centers
  resources :announcements
  resources :loan_products, except: [:destroy]
  resources :member_shares, only: [:index]
  resources :project_type_categories

  resources :surveys, only: [:index, :show, :edit, :update] do
    get "/survey_question_form", to: "surveys#survey_question_form"
  end
end
