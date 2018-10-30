Rails.application.routes.draw do
  devise_for :users, skip: [:sessions]

  as :user do
    get 'login', to: 'pages#login', as: :new_user_session
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  root to: "pages#index"

  # Members
  get "/members", to: "members#index"
  get "/members/:id/display", to: "members#show", as: :member
  get "/members/form", to: "members#form", as: :member_form

  # Loans
  resources :loans, only: [:index, :show] 

  # Accounts
  get "/savings_accounts", to: "savings_accounts#index"
  get "/savings_accounts/:id", to: "savings_accounts#show", as: :savings_account

  # Accounting
  get "/accounting/trial_balance", to: "accounting#trial_balance"
  get "/accounting/general_ledger", to: "accounting#general_ledger"
  get "/accounting/books/jvb", to: "accounting#jvb", as: :accounting_books_jvb
  get "/accounting/books/crb", to: "accounting#crb", as: :accounting_books_crb
  get "/accounting/books/cdb", to: "accounting#cdb", as: :accounting_books_cdb
  get "/accounting/form", to: "accounting#form", as: :accounting_form

  # Billing
  resources :billings, only: [:index, :show, :destroy]

  # Printing
  get "/print", to: "print#print"

  namespace :accounting do
    get "/accounting_entries", to: "acounting_entries#index", as: :accounting_entries
    get "/accounting_entries/:id", to: "accounting_entries#show", as: :accounting_entry
    delete "/accounting_entries/:id", to: "accounting_entries#destroy", as: :delete_accounting_entry
    get "/accounting_entry/form", to: "accounting_entries#form", as: :accounting_entry_form
  end

  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end

  get "/download_backup", to: "pages#download_backup"

  draw :administration
  draw :accounting
  draw :api
end
