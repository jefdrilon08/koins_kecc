Rails.application.routes.draw do
  devise_for :users, skip: [:sessions]

  as :user do
    get 'login', to: 'pages#login', as: :new_user_session
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  # export tools page
  get "/export_tools", to: "pages#export_tools"

  # EXPORTS
  get "/exports/members", to: "exports#members", as: :export_members
  get "/exports/beneficiaries", to: "exports#beneficiaries", as: :export_beneficiaries
  get "/exports/legal_dependents", to: "exports#legal_dependents", as: :export_legal_dependents
  get "/exports/member_accounts", to: "exports#member_accounts", as: :export_member_accounts
  get "/exports/account_transactions", to: "exports#account_transactions", as: :export_account_transactions

  root to: "pages#index"

  # Monitoring
  get "/monitoring/accounting_entry_subsidiary_balancing", to: "monitoring#accounting_entry_subsidiary_balancing", as: :monitoring_accounting_entry_subsidiary_balancing
  get "/monitoring/accounting_entry_precision", to: "monitoring#accounting_entry_precision", as: :monitoring_accounting_entry_precision

  # Members
  get "/members", to: "members#index"
  get "/members/:id/display", to: "members#show", as: :member
  get "/members/:id/form_resignation", to: "members#form_resignation", as: :member_form_resignation
  get "/members/form", to: "members#form", as: :member_form
  get "/members/:id/survey_answers/:survey_answer_id", to: "members#survey_answer", as: :member_survey_answer
  get "/members/:id/survey_answers/:survey_answer_id/form", to: "members#survey_answer_form", as: :member_survey_answer_form

  resources :members, only: [] do
    resources :member_shares, except: [:index], controller: "members/member_shares"
  end

  # Loans
  resources :loans, only: [:index, :show] do
  end

  get "/loans/form/display", to: "loans#form", as: :loan_application_form

  # Accounts
  get "/savings_accounts", to: "savings_accounts#index"
  get "/savings_accounts/:id", to: "savings_accounts#show", as: :savings_account

  get "/insurance_accounts", to: "insurance_accounts#index"
  get "/insurance_accounts/:id", to: "insurance_accounts#show", as: :insurance_account

  get "/equity_accounts", to: "equity_accounts#index"
  get "/equity_accounts/:id", to: "equity_accounts#show", as: :equity_account

  # Accounting
  get "/accounting/trial_balance", to: "accounting#trial_balance"
  get "/accounting/general_ledger", to: "accounting#general_ledger"
  get "/accounting/books/jvb", to: "accounting#jvb", as: :accounting_books_jvb
  get "/accounting/books/crb", to: "accounting#crb", as: :accounting_books_crb
  get "/accounting/books/cdb", to: "accounting#cdb", as: :accounting_books_cdb
  get "/accounting/books/misc", to: "accounting#misc", as: :accounting_books_misc
  get "/accounting/form", to: "accounting#form", as: :accounting_form

  namespace :accounting do
    resources :year_end_closings, only: [:index, :show, :destroy]
  end

  # Billing
  resources :billings, only: [:index, :show, :destroy]

  ################################
  # CASH MANAGEMENT
  ################################

  # Deposits
  resources :deposit_collections, only: [:index, :show, :destroy]

  # Withdrawals
  resources :withdrawal_collections, only: [:index, :show, :destroy]

  # Memberhsip Payment Collections
  resources :membership_payment_collections, only: [:index, :show, :destroy]

  # Monthly Closing Collections
  resources :monthly_closing_collections, only: [:index, :show, :destroy]

  # Printing
  get "/print", to: "print#print"

  # Data Stores
  namespace :data_stores do
    get "/personal_funds", to: "personal_funds#index"
    get "/personal_funds/:id", to: "personal_funds#show"
    delete "/personal_funds/:id", to: "personal_funds#destroy"

    get "/member_counts", to: "member_counts#index"
    get "/member_counts/:id", to: "member_counts#show"
    delete "/member_counts/:id", to: "member_counts#destroy"

    get "/branch_loans_stats", to: "branch_loans_stats#index"
    get "/branch_loans_stats/:id", to: "branch_loans_stats#show"
    delete "/branch_loans_stats/:id", to: "branch_loans_stats#destroy"

    get "/branch_with_centers_loans_stats", to: "branch_with_centers_loans_stats#index"
    get "/branch_with_centers_loans_stats/:id", to: "branch_with_centers_loans_stats#show"
    delete "/branch_with_centers_loans_stats/:id", to: "branch_with_centers_loans_stats#destroy"

    get "/branch_repayment_reports", to: "branch_repayment_reports#index"
    get "/branch_repayment_reports/:id", to: "branch_repayment_reports#show"
    delete "/branch_repayment_reports/:id", to: "branch_repayment_reports#destroy"

    get "/accounting_entries_summaries", to: "accounting_entries_summaries#index"
    get "/accounting_entries_summaries/:id", to: "accounting_entries_summaries#show"
    delete "/accounting_entries_summaries/:id", to: "accounting_entries_summaries#destroy"

    get "/soa_expenses", to: "soa_expenses#index"
    get "/soa_expenses/:id", to: "soa_expenses#show"
    delete "/soa_expenses/:id", to: "soa_expenses#destroy"

    get "/soa_loans", to: "soa_loans#index"
    get "/soa_loans/:id", to: "soa_loans#show"
    delete "/soa_loans/:id", to: "soa_loans#destroy"

    get "/soa_funds", to: "soa_funds#index"
    get "/soa_funds/:id", to: "soa_funds#show"
    delete "/soa_funds/:id", to: "soa_funds#destroy"

    get "/watchlists", to: "watchlists#index"
    get "/watchlists/:id", to: "watchlists#show"
    delete "/watchlists/:id", to: "watchlists#destroy"

    get "/repayment_rates", to: "repayment_rates#index"
    get "/repayment_rates/:id", to: "repayment_rates#show"
    delete "/repayment_rates/:id", to: "repayment_rates#destroy"
  end

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
