namespace :administration do
  resources :users, except: [:destroy] do
    resources :user_demerits
  end

  resources :account_transactions, only: [:show]
  resources :areas
  resources :clusters
  resources :branches
  resources :centers
  resources :announcements
  resources :loan_products, except: [:destroy]
  
  resources :member_shares, only: [:index]
  get "/member_shares/not_printed", to: "member_shares#not_printed"
  get "/member_shares/printed", to: "member_shares#printed"
  get "/member_shares/no_certificates", to: "member_shares#no_certificates"
  get "/member_shares/print", to: "member_shares#print"

  resources :project_type_categories

  resources :surveys, only: [:index, :show, :edit, :update] do
    get "/survey_question_form", to: "surveys#survey_question_form"
  end

  # Static pages
  get "/loan_products/download/json", to: "loan_products#download", as: :download_loan_products
end
